-- Fix: list_students_with_status now returns the actual paid_at from the
-- payments table as last_payment_date, instead of the value stored in
-- students.last_payment_date (which could have been set to the due date).
-- No changes to return columns or Dart code required.

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
      s.photo_url,
      s.created_at,
      s.is_active,
      date_trunc('day', now())::date as today,
      exists (
        select 1 from public.payments p
        where p.student_id = s.id
          and date_trunc('month', p.competence_date) = date_trunc('month', now())
      ) as paid_this_month,
      -- Use actual paid_at from payments table (real date payment was recorded)
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
      when b.paid_this_month then 'paid'
      when b.next_due_date is null then 'pending'
      when b.today > b.next_due_date::date then 'overdue'
      when (b.next_due_date::date - b.today) <= 2 then 'due_soon'
      else 'pending'
    end as payment_status,
    b.is_active
  from base b
  order by b.created_at desc;
$$;
