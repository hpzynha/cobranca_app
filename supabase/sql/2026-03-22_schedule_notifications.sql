-- Habilita pg_cron (necessário apenas uma vez por projeto)
create extension if not exists pg_cron;

-- Agenda a Edge Function notify-due-students todo dia às 08:00 BRT (11:00 UTC)
-- Substitua os valores entre <> pelos seus antes de rodar
select cron.schedule(
  'notify-due-students-daily',         -- nome do job (único)
  '0 11 * * *',                        -- cron: 11:00 UTC = 08:00 BRT
  $$
  select net.http_post(
    url     := 'https://<SEU_PROJECT_ID>.supabase.co/functions/v1/notify-due-students',
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer <SUA_SERVICE_ROLE_KEY>'
    ),
    body    := '{}'::jsonb
  )
  $$
);
