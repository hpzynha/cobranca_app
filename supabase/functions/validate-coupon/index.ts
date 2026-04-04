import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const BASE_PRICE_CENTS = 3990

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Rate limiting: max 10 attempts per IP per minute
const rateLimitMap = new Map<string, { count: number; resetAt: number }>()
const RATE_LIMIT_MAX = 10
const RATE_LIMIT_WINDOW_MS = 60_000

function isRateLimited(ip: string): boolean {
  const now = Date.now()
  const entry = rateLimitMap.get(ip)

  if (!entry || now > entry.resetAt) {
    rateLimitMap.set(ip, { count: 1, resetAt: now + RATE_LIMIT_WINDOW_MS })
    return false
  }

  entry.count++
  if (entry.count > RATE_LIMIT_MAX) return true

  return false
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const ip =
    req.headers.get('x-forwarded-for')?.split(',')[0].trim() ??
    req.headers.get('cf-connecting-ip') ??
    'unknown'

  if (isRateLimited(ip)) {
    return Response.json(
      { valid: false, message: 'Muitas tentativas. Aguarde um momento.' },
      { status: 429, headers: corsHeaders },
    )
  }

  try {
    const { code } = await req.json()

    if (!code || typeof code !== 'string' || code.trim().length === 0 || code.length > 50) {
      return Response.json(
        { valid: false, message: 'Código inválido.' },
        { headers: corsHeaders },
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const { data: coupon, error } = await supabase
      .from('coupons')
      .select('id, code, discount_percent, is_active, max_uses, uses_count, expires_at, is_admin')
      .eq('code', code.toUpperCase().trim())
      .maybeSingle()

    if (error || !coupon) {
      return Response.json(
        { valid: false, message: 'Cupom inválido ou expirado.' },
        { headers: corsHeaders },
      )
    }

    if (!coupon.is_active) {
      return Response.json(
        { valid: false, message: 'Cupom inválido ou expirado.' },
        { headers: corsHeaders },
      )
    }

    if (coupon.expires_at && new Date(coupon.expires_at) < new Date()) {
      return Response.json(
        { valid: false, message: 'Cupom inválido ou expirado.' },
        { headers: corsHeaders },
      )
    }

    if (coupon.max_uses !== null && coupon.uses_count >= coupon.max_uses) {
      return Response.json(
        { valid: false, message: 'Cupom atingiu o limite de usos.' },
        { headers: corsHeaders },
      )
    }

    const discountPercent: number = coupon.discount_percent ?? 0
    const finalPriceCents = Math.round(BASE_PRICE_CENTS - (BASE_PRICE_CENTS * discountPercent / 100))

    if (coupon.is_admin) {
      return Response.json(
        {
          valid: true,
          discount_percent: 100,
          is_admin: true,
          final_price_cents: 0,
          message: 'Cupom admin aplicado! Acesso Pro ativado sem pagamento.',
        },
        { headers: corsHeaders },
      )
    }

    return Response.json(
      {
        valid: true,
        discount_percent: discountPercent,
        is_admin: false,
        final_price_cents: finalPriceCents,
        message: `Cupom aplicado! ${discountPercent}% de desconto.`,
      },
      { headers: corsHeaders },
    )
  } catch (_) {
    return Response.json(
      { valid: false, message: 'Erro ao validar cupom.' },
      { status: 500, headers: corsHeaders },
    )
  }
})
