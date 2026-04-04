-- Migration: create coupons table

create table if not exists public.coupons (
  id               uuid primary key default gen_random_uuid(),
  code             text unique not null,
  discount_percent int  not null default 0,
  is_active        boolean not null default true,
  max_uses         int,           -- null = ilimitado
  uses_count       int  not null default 0,
  expires_at       timestamptz,   -- null = sem expiração
  is_admin         boolean not null default false,
  created_at       timestamptz not null default now()
);

-- Store codes always in uppercase
create or replace function public.normalize_coupon_code()
returns trigger
language plpgsql
as $$
begin
  new.code := upper(trim(new.code));
  return new;
end;
$$;

drop trigger if exists coupon_code_uppercase on public.coupons;
create trigger coupon_code_uppercase
  before insert or update on public.coupons
  for each row execute procedure public.normalize_coupon_code();

-- RLS: anyone can read (for coupon validation); writes only via service_role
alter table public.coupons enable row level security;

drop policy if exists "coupons: public read" on public.coupons;
create policy "coupons: public read"
  on public.coupons for select
  using (true);
