-- Tabela de beta testers do Mensalify
create table if not exists public.beta_testers (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  email       text not null unique,
  device      text not null check (device in ('android', 'iphone')),
  whatsapp    text,
  created_at  timestamptz not null default now()
);

-- RLS
alter table public.beta_testers enable row level security;

-- Somente service_role pode ler (dashboard interno)
create policy "service_role full access"
  on public.beta_testers
  for all
  using (auth.role() = 'service_role');

-- Qualquer visitante pode inserir (formulário público)
create policy "public insert"
  on public.beta_testers
  for insert
  with check (true);
