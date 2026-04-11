-- Fix: mark_student_as_paid was setting next_due_date to the current month's
-- due date when payment happened before the due date. This caused the student
-- to appear as overdue as soon as that date passed, even though they had paid.
--
-- Fix: always advance next_due_date to the due_day of the NEXT month,
-- regardless of whether the current month's due date has passed or not.

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
  v_student  public.students%rowtype;
  v_today    date;
  v_next_due date;
  v_was_late boolean;
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

  -- Always advance to due_day of next month, clamped to last day of that month
  v_next_due := make_date(
    extract(year  from (v_today + interval '1 month'))::int,
    extract(month from (v_today + interval '1 month'))::int,
    least(
      greatest(v_student.due_day, 1),
      extract(day from (
        date_trunc('month', v_today + interval '1 month') + interval '1 month - 1 day'
      ))::int
    )
  );

  insert into public.payments (student_id, owner_id, amount_cents, competence_date, paid_at)
  values (
    p_student_id,
    auth.uid(),
    v_student.monthly_fee_cents,
    date_trunc('month', v_today)::date,
    v_today
  );

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
