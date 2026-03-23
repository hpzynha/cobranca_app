-- Tabela para armazenar tokens FCM por usuário (personal)
create table if not exists public.fcm_tokens (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  token text not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(owner_id, token)
);

alter table public.fcm_tokens enable row level security;

create policy "Users manage own tokens"
  on public.fcm_tokens
  for all
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);
