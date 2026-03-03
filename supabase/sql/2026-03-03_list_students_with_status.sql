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
