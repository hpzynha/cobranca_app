-- Fix: list_students_with_status status logic
--
-- Old logic:
--   paid      → paid_this_month (payment exists in current calendar month)
--   overdue   → today > next_due_date (checked before due_soon)
--   due_soon  → (next_due_date - today) <= 2
--
-- New logic:
--   paid      → last_payment_date IS NOT NULL AND today < next_due_date
--               (student paid at some point and the next due date has not arrived)
--   due_soon  → (next_due_date - today) <= 3 AND today <= next_due_date
--               (checked BEFORE overdue so the due date itself is due_soon)
--   overdue   → today > next_due_date
--   pending   → everything else (no next_due_date, never paid, etc.)
--
-- This fixes the edge case where a student pays before the due date:
--   paid 09/04, due_day = 10 → next_due_date = 10/05
--   stays 'paid' until 06/05, then 'due_soon' 07–10/05, then 'overdue'

create or replace function public.list_students_with_status()
returns table (
  id                uuid,
  owner_id          uuid,
  name              text,
  whatsapp          text,
  monthly_fee_cents integer,
  due_day           integer,
  next_due_date     timestamptz,
  last_payment_date timestamptz,
  photo_url         text,
  created_at        timestamptz,
  payment_status    text,
  is_active         boolean
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
      s.photo_url,
      s.created_at,
      s.is_active,
      date_trunc('day', now())::date as today,
      (
        select p.paid_at::timestamptz
        from public.payments p
        where p.student_id = s.id
        order by p.paid_at desc
        limit 1
      ) as actual_last_payment_date
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
    b.actual_last_payment_date as last_payment_date,
    b.photo_url,
    b.created_at,
    case
      when b.actual_last_payment_date is not null
        and b.next_due_date is not null
        and b.today < b.next_due_date::date       then 'paid'
      when b.next_due_date is null                then 'pending'
      when b.today <= b.next_due_date::date
        and (b.next_due_date::date - b.today) <= 3 then 'due_soon'
      when b.today > b.next_due_date::date        then 'overdue'
      else 'pending'
    end as payment_status,
    b.is_active
  from base b
  order by b.created_at desc;
$$;
