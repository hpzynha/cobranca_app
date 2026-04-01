import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const ABACATEPAY_BASE = 'https://api.abacatepay.com/v1'
const BASE_PRICE_CENTS = 3990

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

async function abacatePost(path: string, apiKey: string, body: object) {
  const res = await fetch(`${ABACATEPAY_BASE}${path}`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  })
  const json = await res.json()
  console.log(`abacate POST ${path} →`, JSON.stringify(json))
  return json
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Authenticate the caller
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return Response.json(
        { success: false, message: 'Não autorizado.' },
        { status: 401, headers: corsHeaders },
      )
    }

    const supabaseUser = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } },
    )

    const { data: { user }, error: userError } = await supabaseUser.auth.getUser()
    if (userError || !user) {
      return Response.json(
        { success: false, message: 'Sessão inválida.' },
        { status: 401, headers: corsHeaders },
      )
    }

    const apiKey = Deno.env.get('ABACATEPAY_API_KEY')
    if (!apiKey) {
      return Response.json(
        { success: false, message: 'Pagamentos não configurados.' },
        { status: 500, headers: corsHeaders },
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const fullName = (user.user_metadata?.full_name as string | undefined) ?? ''

    // Create billing with inline customer (avoids customer lookup issues)
    const billingRes = await abacatePost('/billing/create', apiKey, {
      frequency: 'ONE_TIME',
      methods: ['PIX'],
      products: [
        {
          externalId: 'mensalify-pro-monthly',
          name: 'Mensalify Pro',
          description: 'Plano Pro — alunos ilimitados e cobranças automáticas via WhatsApp',
          quantity: 1,
          price: BASE_PRICE_CENTS,
        },
      ],
      returnUrl: 'https://mensalify.com.br/payment-return',
      completionUrl: 'https://mensalify.com.br/payment-return',
      externalId: user.id,
      customer: {
        name: fullName.trim() || user.email,
        email: user.email,
        cellphone: '+5511999999999',
        taxId: '11144477735',
      },
    })

    const url: string | undefined = billingRes?.data?.url
    const billingId: string | undefined = billingRes?.data?.id

    if (!url) {
      console.error('create-billing: no url in response', JSON.stringify(billingRes))
      return Response.json(
        { success: false, message: 'Erro ao gerar link de pagamento.' },
        { status: 500, headers: corsHeaders },
      )
    }

    // Record a pending subscription
    if (billingId) {
      await supabase.from('subscriptions').insert({
        owner_id: user.id,
        abacatepay_subscription_id: billingId,
        status: 'pending',
        amount_cents: BASE_PRICE_CENTS,
      })
    }

    return Response.json({ success: true, url }, { headers: corsHeaders })
  } catch (err) {
    console.error('create-billing error', err)
    return Response.json(
      { success: false, message: 'Erro interno ao criar cobrança.' },
      { status: 500, headers: corsHeaders },
    )
  }
})
