-- ============================================================
-- payment_history table + updated mark_student_as_paid +
-- list_available_months() + get_monthly_report(year, month)
-- ============================================================

-- 1. Create payment_history table
create table if not exists public.payment_history (
  id             uuid        primary key default gen_random_uuid(),
  student_id     uuid        references public.students(id) on delete cascade not null,
  owner_id       uuid        references auth.users(id) on delete cascade not null,
  paid_at        date        not null,
  amount_cents   integer     not null,
  reference_month date       not null,  -- always the first day of the month, e.g. 2026-04-01
  created_at     timestamptz default now()
);

alter table public.payment_history enable row level security;

create policy "payment_history_select_own" on public.payment_history
  for select using (auth.uid() = owner_id);

create policy "payment_history_insert_own" on public.payment_history
  for insert with check (auth.uid() = owner_id);

-- 2. Update mark_student_as_paid to also write to payment_history
create or replace function public.mark_student_as_paid(p_student_id uuid)
returns table (
  last_payment_date timestamptz,
  next_due_date     timestamptz,
  payment_status    text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_student         public.students%rowtype;
  v_today           date;
  v_current_month_due date;
  v_next_due        date;
begin
  if auth.uid() is null then
    raise exception 'Usuário não autenticado.';
  end if;

  select *
    into v_student
    from public.students s
   where s.id = p_student_id
     and s.owner_id = auth.uid()
   for update;

  if not found then
    raise exception 'Aluno não encontrado para este usuário.';
  end if;

  v_today := (now() at time zone 'UTC')::date;

  v_current_month_due := make_date(
    extract(year from v_today)::int,
    extract(month from v_today)::int,
    least(
      greatest(v_student.due_day, 1),
      extract(day from (date_trunc('month', v_today) + interval '1 month - 1 day'))::int
    )
  );

  if v_current_month_due <= v_today then
    v_next_due := make_date(
      extract(year from (v_today + interval '1 month'))::int,
      extract(month from (v_today + interval '1 month'))::int,
      least(
        greatest(v_student.due_day, 1),
        extract(day from (date_trunc('month', v_today + interval '1 month') + interval '1 month - 1 day'))::int
      )
    );
  else
    v_next_due := v_current_month_due;
  end if;

  -- Existing payments table insert (unchanged)
  insert into public.payments (student_id, owner_id, amount_cents, competence_date, paid_at)
  values (
    p_student_id,
    auth.uid(),
    v_student.monthly_fee_cents,
    date_trunc('month', v_today)::date,
    v_today
  );

  -- New payment_history insert for historical reports
  insert into public.payment_history (student_id, owner_id, paid_at, amount_cents, reference_month)
  values (
    p_student_id,
    auth.uid(),
    v_today,
    v_student.monthly_fee_cents,
    date_trunc('month', v_today)::date
  );

  update public.students
     set last_payment_date = v_today::timestamptz,
         next_due_date     = v_next_due::timestamptz
   where id = p_student_id
     and owner_id = auth.uid();

  return query
  select
    v_today::timestamptz   as last_payment_date,
    v_next_due::timestamptz as next_due_date,
    'paid'::text            as payment_status;
end;
$$;

-- 3. list_available_months: distinct months with payments + always current month
create or replace function public.list_available_months()
returns table (year int, month int, label text)
language sql
security definer
set search_path = public
as $$
  with months_from_history as (
    select distinct
      extract(year  from reference_month)::int as yr,
      extract(month from reference_month)::int as mo
    from public.payment_history
    where owner_id = auth.uid()
  ),
  all_months as (
    select yr, mo from months_from_history
    union
    select
      extract(year  from current_date)::int,
      extract(month from current_date)::int
  )
  select
    yr as year,
    mo as month,
    (array[
      'janeiro','fevereiro','março','abril','maio','junho',
      'julho','agosto','setembro','outubro','novembro','dezembro'
    ])[mo] || ' ' || yr::text as label
  from all_months
  order by yr desc, mo desc;
$$;

grant execute on function public.list_available_months() to authenticated;

-- 4. get_monthly_report(p_year, p_month): aggregated report for a given month
--    Rewritten as language sql (single SELECT with CTEs) to avoid plpgsql semicolons
--    that cause issues in the Supabase SQL editor.
--    Coexists with get_monthly_report(date) — different signature (int, int vs date)
create or replace function public.get_monthly_report(p_year int, p_month int)
returns table (
  expected_cents integer,
  received_cents integer,
  due_soon_cents integer,
  overdue_cents  integer
)
language sql
security definer
set search_path = public
as $$
  with
  params as (
    select
      make_date(p_year, p_month, 1) as ref_month,
      (p_year  = extract(year  from current_date)::int
   and p_month = extract(month from current_date)::int) as is_current
  ),
  expected_cte as (
    select coalesce(sum(monthly_fee_cents), 0)::integer as total
    from public.students
    where owner_id = auth.uid()
      and is_active = true
  ),
  received_cte as (
    select coalesce(sum(ph.amount_cents), 0)::integer as total
    from public.payment_history ph, params
    where ph.owner_id = auth.uid()
      and ph.reference_month = params.ref_month
  ),
  due_soon_cte as (
    select coalesce(sum(s.monthly_fee_cents), 0)::integer as total
    from public.students s, params
    where s.owner_id = auth.uid()
      and s.is_active = true
      and params.is_current = true
      and s.next_due_date::date >= current_date
      and s.next_due_date::date <= current_date + interval '5 days'
      and not exists (
        select 1 from public.payment_history ph
        where ph.student_id = s.id
          and ph.reference_month = params.ref_month
      )
  ),
  overdue_cte as (
    select
      case
        when params.is_current then
          coalesce((
            select sum(s.monthly_fee_cents)::integer
            from public.students s
            where s.owner_id = auth.uid()
              and s.is_active = true
              and s.next_due_date < now()
              and not exists (
                select 1 from public.payment_history ph
                where ph.student_id = s.id
                  and ph.reference_month = params.ref_month
              )
          ), 0)
        else greatest(expected_cte.total - received_cte.total, 0)
      end as total
    from params, expected_cte, received_cte
  )
  select
    expected_cte.total,
    received_cte.total,
    due_soon_cte.total,
    overdue_cte.total
  from expected_cte, received_cte, due_soon_cte, overdue_cte
$$;

grant execute on function public.get_monthly_report(int, int) to authenticated;
