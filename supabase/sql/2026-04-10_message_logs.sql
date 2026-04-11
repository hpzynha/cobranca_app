-- Creates message_logs table to store WhatsApp notification history.
-- Insert is done via service role (Edge Function).
-- Select is restricted to the owner via RLS.

create table if not exists public.message_logs (
  id           uuid primary key default gen_random_uuid(),
  owner_id     uuid references auth.users(id) on delete cascade not null,
  student_id   uuid references public.students(id) on delete set null,
  student_name text not null,
  template     text not null,
  status       text not null check (status in ('sent', 'failed')),
  error_msg    text,
  sent_at      timestamptz not null default now()
);

alter table public.message_logs enable row level security;

create policy "owners can view own message logs"
  on public.message_logs
  for select
  using (owner_id = auth.uid());
