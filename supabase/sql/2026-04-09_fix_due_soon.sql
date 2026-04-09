-- Fix: get_monthly_report due_soon_cte was using params.ref_month for the
-- NOT EXISTS check instead of current_date. When is_current = true they are
-- the same month, but using current_date directly avoids any type-comparison
-- ambiguity and is consistent with how list_students_with_status works.

-- Run step 1 alone first
drop function if exists public.get_monthly_report(int, int);

-- Then run step 2 alone
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
    -- Uses current_date (not params.ref_month) for the paid check — same value
    -- when is_current = true, but avoids type-comparison edge cases.
    select coalesce(sum(s.monthly_fee_cents), 0)::integer as total
    from public.students s, params
    where s.owner_id = auth.uid()
      and s.is_active = true
      and params.is_current = true
      and s.next_due_date::date >= current_date
      and (s.next_due_date::date - current_date) <= 2
      and not exists (
        select 1 from public.payments p
        where p.student_id = s.id
          and date_trunc('month', p.competence_date) = date_trunc('month', current_date)
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
              and s.next_due_date::date < current_date
              and not exists (
                select 1 from public.payments p
                where p.student_id = s.id
                  and date_trunc('month', p.competence_date) = date_trunc('month', current_date)
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
