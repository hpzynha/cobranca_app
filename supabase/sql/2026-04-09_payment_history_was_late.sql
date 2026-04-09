-- ============================================================
-- Parte 1: add was_late column to payment_history
-- Run this block alone first
-- ============================================================

alter table public.payment_history
  add column if not exists was_late boolean not null default false;

-- ============================================================
-- Parte 2: update mark_student_as_paid to set was_late
-- Run this block alone (plpgsql)
-- ============================================================

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
  v_student           public.students%rowtype;
  v_today             date;
  v_current_month_due date;
  v_next_due          date;
  v_was_late          boolean;
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

  -- was_late: true if the student was already overdue before this payment
  v_was_late := (v_student.next_due_date is not null and v_today > v_student.next_due_date::date);

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

  -- payment_history insert with was_late flag
  insert into public.payment_history (student_id, owner_id, paid_at, amount_cents, reference_month, was_late)
  values (
    p_student_id,
    auth.uid(),
    v_today,
    v_student.monthly_fee_cents,
    date_trunc('month', v_today)::date,
    v_was_late
  );

  update public.students
     set last_payment_date = v_today::timestamptz,
         next_due_date     = v_next_due::timestamptz
   where id = p_student_id
     and owner_id = auth.uid();

  return query
  select
    v_today::timestamptz    as last_payment_date,
    v_next_due::timestamptz as next_due_date,
    'paid'::text            as payment_status;
end;
$$;

-- ============================================================
-- Parte 3: update get_monthly_report to return late_received_cents
-- Run this block alone (language sql)
-- ============================================================

create or replace function public.get_monthly_report(p_year int, p_month int)
returns table (
  expected_cents      integer,
  received_cents      integer,
  due_soon_cents      integer,
  overdue_cents       integer,
  late_received_cents integer
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
  late_received_cte as (
    select coalesce(sum(ph.amount_cents), 0)::integer as total
    from public.payment_history ph, params
    where ph.owner_id = auth.uid()
      and ph.reference_month = params.ref_month
      and ph.was_late = true
  ),
  due_soon_cte as (
    -- Uses payments table (full history) so students who paid before due date are excluded
    select coalesce(sum(s.monthly_fee_cents), 0)::integer as total
    from public.students s, params
    where s.owner_id = auth.uid()
      and s.is_active = true
      and params.is_current = true
      and s.next_due_date::date >= current_date
      and s.next_due_date::date <= current_date + interval '5 days'
      and not exists (
        select 1 from public.payments p
        where p.student_id = s.id
          and date_trunc('month', p.competence_date) = date_trunc('month', params.ref_month)
      )
  ),
  overdue_cte as (
    -- next_due_date::date < current_date: today is NOT overdue, only strictly past days
    -- Uses payments table (full history) so paid students are excluded
    select
      case
        when params.is_current then
          coalesce((
            select sum(s.monthly_fee_cents)::integer
            from public.students s
            where s.owner_id = auth.uid()
              and s.is_active = true
              and s.next_due_date::date < current_date
              and not exists (
                select 1 from public.payments p
                where p.student_id = s.id
                  and date_trunc('month', p.competence_date) = date_trunc('month', params.ref_month)
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
    overdue_cte.total,
    late_received_cte.total
  from expected_cte, received_cte, late_received_cte, due_soon_cte, overdue_cte
$$;

grant execute on function public.get_monthly_report(int, int) to authenticated;
