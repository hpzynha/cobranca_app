import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { name, email, device } = await req.json()

    if (!name || !email || !device) {
      return new Response(JSON.stringify({ error: 'Dados incompletos' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const firstName = name.split(' ')[0]
    const deviceLabel = device === 'android' ? 'Android' : 'iPhone'

    const html = `<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
</head>
<body style="margin:0;padding:0;background:#F5F4F0;font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#F5F4F0;padding:40px 16px;">
    <tr>
      <td align="center">
        <table width="100%" cellpadding="0" cellspacing="0" border="0" style="max-width:520px;">

          <!-- LOGO -->
          <tr>
            <td align="center" style="padding-bottom:32px;">
              <table cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td style="background:#534AB7;border-radius:14px;width:44px;height:44px;text-align:center;vertical-align:middle;">
                    <span style="font-family:Georgia,serif;font-size:24px;font-weight:700;color:#ffffff;line-height:44px;">M</span>
                  </td>
                  <td style="padding-left:10px;vertical-align:middle;">
                    <span style="font-family:Georgia,serif;font-size:20px;color:#1a1830;letter-spacing:-0.3px;">
                      <strong>mensal</strong><span style="font-weight:300;color:#7F77DD;">ify</span>
                    </span>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- CARD -->
          <tr>
            <td style="background:#ffffff;border-radius:20px;padding:40px 40px 36px;box-shadow:0 4px 24px rgba(0,0,0,0.07);">

              <p style="text-align:center;font-size:48px;margin:0 0 20px;">🎉</p>

              <h1 style="font-family:Georgia,serif;font-size:26px;color:#1A1830;margin:0 0 8px;text-align:center;line-height:1.2;">
                Você está na lista, ${firstName}!
              </h1>
              <p style="font-size:15px;color:#4A4760;text-align:center;margin:0 0 32px;line-height:1.6;">
                Obrigado por se cadastrar como beta tester do Mensalify. Anotei aqui que você usa <strong>${deviceLabel}</strong>.
              </p>

              <div style="background:#F5F4F0;border-radius:12px;padding:24px 20px;margin-bottom:28px;">
                <p style="font-size:13px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase;color:#534AB7;margin:0 0 12px;">O que acontece agora</p>
                <p style="font-size:14px;color:#4A4760;margin:0;line-height:1.75;">
                  Estou finalizando os últimos ajustes no app. Assim que estiver pronto,
                  te mando o link de instalação direto nesse email. Pode ser que leve alguns dias.
                </p>
              </div>

              <div style="border-left:3px solid #534AB7;padding-left:16px;margin-bottom:28px;">
                <p style="font-size:14px;color:#4A4760;margin:0;line-height:1.65;">
                  Enquanto isso, se tiver alguma dúvida ou quiser conversar, me manda um direct no Instagram
                  <a href="https://instagram.com/mensalify" style="color:#534AB7;text-decoration:none;font-weight:600;">@mensalify</a>
                  ou é só responder esse email.
                </p>
              </div>

              <p style="font-size:15px;color:#4A4760;margin:0;line-height:1.6;">
                Valeu demais pela confiança. 🙏
              </p>
            </td>
          </tr>

          <!-- FOOTER -->
          <tr>
            <td style="padding:24px 0;text-align:center;">
              <p style="font-size:12px;color:#8A87A8;margin:0;line-height:1.6;">
                Mensalify · Seu trabalho vale. Cobre por ele.<br />
                <a href="https://mensalify.com.br" style="color:#8A87A8;">mensalify.com.br</a>
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'Mensalify <oi@mensalify.com.br>',
        reply_to: 'oi@mensalify.com.br',
        to: [email],
        subject: `${firstName}, você está na lista do beta! 🎉`,
        html,
      }),
    })

    if (!res.ok) {
      const err = await res.json()
      throw new Error('Resend error: ' + JSON.stringify(err))
    }

    return new Response(JSON.stringify({ ok: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (err) {
    console.error(err)
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
