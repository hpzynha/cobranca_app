-- Initial coupons seed data
-- Run after create_coupons_table.sql

insert into public.coupons (code, discount_percent, is_active, max_uses, is_admin)
values ('MENSALIFY_ADMIN', 100, true, null, true)
on conflict (code) do update
  set discount_percent = excluded.discount_percent,
      is_active        = excluded.is_active,
      max_uses         = excluded.max_uses,
      is_admin         = excluded.is_admin;

insert into public.coupons (code, discount_percent, is_active, max_uses, is_admin)
values ('LAUNCH20', 20, true, 100, false)
on conflict (code) do update
  set discount_percent = excluded.discount_percent,
      is_active        = excluded.is_active,
      max_uses         = excluded.max_uses,
      is_admin         = excluded.is_admin;
