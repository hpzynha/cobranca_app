-- Migration: add plan fields to profiles table
-- Run this if the profiles table already exists (alter); if not, create it.

create table if not exists public.profiles (
  id                       uuid primary key references auth.users(id) on delete cascade,
  plan                     text not null default 'free',
  plan_activated_at        timestamptz,
  plan_expires_at          timestamptz,
  abacatepay_customer_id   text,
  pix_key                  text,
  service_type             text,
  service_custom           text,
  updated_at               timestamptz,
  created_at               timestamptz not null default now()
);

-- Add plan columns to existing table (safe with IF NOT EXISTS via DO block)
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name   = 'profiles'
      and column_name  = 'plan'
  ) then
    alter table public.profiles add column plan text not null default 'free';
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name   = 'profiles'
      and column_name  = 'plan_activated_at'
  ) then
    alter table public.profiles add column plan_activated_at timestamptz;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name   = 'profiles'
      and column_name  = 'plan_expires_at'
  ) then
    alter table public.profiles add column plan_expires_at timestamptz;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name   = 'profiles'
      and column_name  = 'abacatepay_customer_id'
  ) then
    alter table public.profiles add column abacatepay_customer_id text;
  end if;
end;
$$;

-- RLS
alter table public.profiles enable row level security;

drop policy if exists "profiles: owner read"   on public.profiles;
drop policy if exists "profiles: owner update" on public.profiles;

create policy "profiles: owner read"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles: owner update"
  on public.profiles for update
  using (auth.uid() = id);

-- Trigger: auto-create profile on new user signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
