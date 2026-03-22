create or replace function public.list_students_with_status()
returns table (
  id uuid,
  owner_id uuid,
  name text,
  whatsapp text,
  monthly_fee_cents integer,
  due_day integer,
  next_due_date timestamptz,
  last_payment_date timestamptz,
  photo_url text,
  created_at timestamptz,
  payment_status text,
  is_active boolean
)
language sql
security invoker
stable
as $$
  with base as (
    select
      s.id,
      s.owner_id,
      s.name,
      s.whatsapp,
      s.monthly_fee_cents,
      s.due_day,
      s.next_due_date,
      s.last_payment_date,
      s.photo_url,
      s.created_at,
      s.is_active,
      date_trunc('day', now())::date as today,
      exists (
        select 1 from public.payments p
        where p.student_id = s.id
          and date_trunc('month', p.competence_date) = date_trunc('month', now())
      ) as paid_this_month
    from public.students s
    where s.owner_id = auth.uid()
      and s.is_active = true
  )
  select
    b.id,
    b.owner_id,
    b.name,
    b.whatsapp,
    b.monthly_fee_cents,
    b.due_day,
    b.next_due_date,
    b.last_payment_date,
    b.photo_url,
    b.created_at,
    case
      when b.paid_this_month then 'paid'
      when b.next_due_date is null then 'pending'
      when b.today > b.next_due_date::date then 'overdue'
      when (b.next_due_date::date - b.today) <= 5 then 'due_soon'
      else 'pending'
    end as payment_status,
    b.is_active
  from base b
  order by b.created_at desc;
$$;

create or replace function public.mark_student_as_paid(p_student_id uuid)
returns table (
  last_payment_date timestamptz,
  next_due_date timestamptz,
  payment_status text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_student public.students%rowtype;
  v_today date;
  v_current_month_due date;
  v_next_due date;
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

  insert into public.payments (student_id, owner_id, amount_cents, competence_date, paid_at)
  values (
    p_student_id,
    auth.uid(),
    v_student.monthly_fee_cents,
    date_trunc('month', v_today)::date,
    v_today
  );

  update public.students
     set last_payment_date = v_today::timestamptz,
         next_due_date = v_next_due::timestamptz
   where id = p_student_id
     and owner_id = auth.uid();

  return query
  select
    v_today::timestamptz as last_payment_date,
    v_next_due::timestamptz as next_due_date,
    'paid'::text as payment_status;
end;
$$;

grant execute on function public.mark_student_as_paid(uuid) to authenticated;

create or replace function public.get_monthly_report(p_month date)
returns table (
  expected_cents integer,
  received_cents integer,
  due_soon_cents integer,
  pending_cents integer
)
language sql
security definer
set search_path = public
as $$
  with expected as (
    select coalesce(sum(monthly_fee_cents), 0)::integer as total
    from public.students
    where owner_id = auth.uid()
      and is_active = true
  ),
  received as (
    select coalesce(sum(amount_cents), 0)::integer as total
    from public.payments
    where owner_id = auth.uid()
      and date_trunc('month', competence_date) = date_trunc('month', p_month)
  ),
  due_soon as (
    select coalesce(sum(s.monthly_fee_cents), 0)::integer as total
    from public.students s
    where s.owner_id = auth.uid()
      and s.is_active = true
      and s.next_due_date::date >= current_date
      and s.next_due_date::date <= current_date + interval '5 days'
      and not exists (
        select 1 from public.payments p
        where p.student_id = s.id
          and date_trunc('month', p.competence_date) = date_trunc('month', p_month)
      )
  ),
  overdue as (
    select coalesce(sum(s.monthly_fee_cents), 0)::integer as total
    from public.students s
    where s.owner_id = auth.uid()
      and s.is_active = true
      and s.next_due_date < now()
      and not exists (
        select 1 from public.payments p
        where p.student_id = s.id
          and date_trunc('month', p.competence_date) = date_trunc('month', p_month)
      )
  )
  select
    expected.total as expected_cents,
    received.total as received_cents,
    due_soon.total as due_soon_cents,
    overdue.total as pending_cents
  from expected, received, due_soon, overdue;
$$;

grant execute on function public.get_monthly_report(date) to authenticated;
