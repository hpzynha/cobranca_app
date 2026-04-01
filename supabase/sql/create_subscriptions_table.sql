-- Migration: create subscriptions table

create table if not exists public.subscriptions (
  id                          uuid primary key default gen_random_uuid(),
  owner_id                    uuid not null references auth.users(id) on delete cascade,
  coupon_id                   uuid references public.coupons(id),
  abacatepay_subscription_id  text,
  status                      text not null default 'active',
  amount_cents                int  not null default 0,
  created_at                  timestamptz not null default now()
);

-- RLS: user only sees their own subscriptions
alter table public.subscriptions enable row level security;

drop policy if exists "subscriptions: owner read" on public.subscriptions;
create policy "subscriptions: owner read"
  on public.subscriptions for select
  using (auth.uid() = owner_id);
