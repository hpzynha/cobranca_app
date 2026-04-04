import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
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

    const { code } = await req.json()
    if (!code || typeof code !== 'string') {
      return Response.json(
        { success: false, message: 'Código inválido.' },
        { status: 400, headers: corsHeaders },
      )
    }

    // Use service role for writes
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // Validate the admin coupon
    const { data: coupon, error: couponError } = await supabase
      .from('coupons')
      .select('id, is_active, is_admin, max_uses, uses_count')
      .eq('code', code.toUpperCase().trim())
      .maybeSingle()

    if (couponError || !coupon) {
      return Response.json(
        { success: false, message: 'Cupom não encontrado.' },
        { status: 400, headers: corsHeaders },
      )
    }

    if (!coupon.is_active || !coupon.is_admin) {
      return Response.json(
        { success: false, message: 'Cupom inválido.' },
        { status: 400, headers: corsHeaders },
      )
    }

    if (coupon.max_uses !== null && coupon.uses_count >= coupon.max_uses) {
      return Response.json(
        { success: false, message: 'Cupom atingiu o limite de usos.' },
        { status: 400, headers: corsHeaders },
      )
    }

    // Activate Pro on profile (null expires_at = permanent)
    const { error: profileError } = await supabase
      .from('profiles')
      .update({
        plan: 'pro',
        plan_activated_at: new Date().toISOString(),
        plan_expires_at: null,
      })
      .eq('id', user.id)

    if (profileError) {
      return Response.json(
        { success: false, message: 'Erro ao ativar o plano.' },
        { status: 500, headers: corsHeaders },
      )
    }

    // Record the subscription
    await supabase.from('subscriptions').insert({
      owner_id: user.id,
      coupon_id: coupon.id,
      status: 'active',
      amount_cents: 0,
    })

    // Increment coupon uses_count
    await supabase
      .from('coupons')
      .update({ uses_count: coupon.uses_count + 1 })
      .eq('id', coupon.id)

    return Response.json({ success: true }, { headers: corsHeaders })
  } catch (_) {
    return Response.json(
      { success: false, message: 'Erro interno.' },
      { status: 500, headers: corsHeaders },
    )
  }
})
