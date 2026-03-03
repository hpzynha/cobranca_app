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
  payment_status text
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
      date_trunc('day', now())::date as today,
      case
        when s.next_due_date is null then null
        else make_date(
          extract(year from (s.next_due_date - interval '1 month'))::int,
          extract(month from (s.next_due_date - interval '1 month'))::int,
          least(
            greatest(s.due_day, 1),
            extract(day from (date_trunc('month', s.next_due_date - interval '1 month') + interval '1 month - 1 day'))::int
          )
        )
      end as previous_due_date
    from public.students s
    where s.owner_id = auth.uid()
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
      when b.next_due_date is null then 'pending'
      when b.last_payment_date is not null and b.last_payment_date::date >= b.next_due_date::date then 'paid'
      when b.last_payment_date is not null
           and b.previous_due_date is not null
           and b.last_payment_date::date >= b.previous_due_date
           and b.last_payment_date::date < b.next_due_date::date then 'paid'
      when b.today > b.next_due_date::date then 'overdue'
      when (b.next_due_date::date - b.today) <= 2 then 'due_soon'
      else 'pending'
    end as payment_status
  from base b
  order by b.created_at desc;
$$;
