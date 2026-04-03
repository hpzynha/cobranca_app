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
    const isAndroid = device === 'android'

    const installInstructions = isAndroid
      ? `<p style="margin:0 0 12px;">Para instalar no <strong>Android</strong>, siga os passos:</p>
         <ol style="margin:0 0 20px;padding-left:20px;line-height:1.8;">
           <li>Baixe o arquivo APK pelo link abaixo</li>
           <li>Abra o arquivo no seu celular</li>
           <li>Se aparecer um aviso de segurança, toque em <em>"Instalar mesmo assim"</em></li>
           <li>Pronto, o app estará instalado!</li>
         </ol>`
      : `<p style="margin:0 0 12px;">Para instalar no <strong>iPhone</strong> via TestFlight:</p>
         <ol style="margin:0 0 20px;padding-left:20px;line-height:1.8;">
           <li>Instale o app <strong>TestFlight</strong> na App Store (gratuito)</li>
           <li>Clique no link de convite abaixo no seu iPhone</li>
           <li>Toque em <em>"Aceitar"</em> e depois em <em>"Instalar"</em></li>
           <li>Pronto!</li>
         </ol>`

    // TODO: troque estes links pelos seus links reais de distribuição
    const installLink = isAndroid
      ? 'https://mensalify.com.br/beta/mensalify-beta.apk'
      : 'https://testflight.apple.com/join/SEU_CODIGO_AQUI'

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

              <!-- ICON -->
              <p style="text-align:center;font-size:48px;margin:0 0 20px;">🧪</p>

              <!-- HEADING -->
              <h1 style="font-family:Georgia,serif;font-size:26px;color:#1A1830;margin:0 0 8px;text-align:center;line-height:1.2;">
                Você está dentro, ${firstName}!
              </h1>
              <p style="font-size:15px;color:#4A4760;text-align:center;margin:0 0 32px;line-height:1.6;">
                Obrigado por embarcar como beta tester do Mensalify. Aqui está tudo que você precisa pra começar.
              </p>

              <!-- INSTALL -->
              <div style="background:#F5F4F0;border-radius:12px;padding:24px 20px;margin-bottom:28px;">
                <p style="font-size:13px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase;color:#534AB7;margin:0 0 14px;">Como instalar</p>
                ${installInstructions}
                <a href="${installLink}"
                   style="display:inline-block;background:#534AB7;color:#fff;text-decoration:none;padding:14px 28px;border-radius:10px;font-size:15px;font-weight:600;letter-spacing:0.01em;">
                  ${isAndroid ? '⬇️ Baixar APK' : '🍎 Abrir no TestFlight'}
                </a>
              </div>

              <!-- FEEDBACK -->
              <div style="border-left:3px solid #534AB7;padding-left:16px;margin-bottom:28px;">
                <p style="font-size:14px;color:#4A4760;margin:0;line-height:1.65;">
                  Encontrou um bug? Tem uma sugestão? Qualquer coisa me manda um direct no Instagram
                  <a href="https://instagram.com/mensalify" style="color:#534AB7;text-decoration:none;font-weight:600;">@mensalify</a>
                  ou responde esse email. Cada feedback vale ouro.
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
        to: [email],
        subject: `${firstName}, seu acesso beta chegou! 🧪`,
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
