-- Schedule daily WhatsApp notifications at 08:00 BRT (11:00 UTC)
select
  cron.schedule(
    'send-whatsapp-notifications',
    '0 11 * * *',
    $$
    select net.http_post(
      url := (select decrypted_secret from vault.decrypted_secrets where name = 'SUPABASE_URL') || '/functions/v1/send-whatsapp-notifications',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || (select decrypted_secret from vault.decrypted_secrets where name = 'SUPABASE_SERVICE_ROLE_KEY')
      ),
      body := '{}'::jsonb
    )
    $$
  );
