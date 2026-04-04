import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    // AbacatePay sends the webhook secret as a query param:
    // POST /abacatepay-webhook?webhookSecret=<secret>
    const reqUrl = new URL(req.url)
    const receivedSecret = reqUrl.searchParams.get('webhookSecret')
    const expectedSecret = Deno.env.get('ABACATEPAY_WEBHOOK_SECRET')

    if (expectedSecret && receivedSecret !== expectedSecret) {
      console.warn('abacatepay-webhook: invalid secret')
      return new Response('Unauthorized', { status: 401 })
    }

    const body = await req.json()
    const event: string = body?.event ?? ''

    console.log('abacatepay-webhook: received event', event)

    // Only process billing.paid events
    if (event !== 'billing.paid') {
      return new Response(JSON.stringify({ received: true }), { status: 200 })
    }

    // AbacatePay billing.paid payload shape:
    // {
    //   event: 'billing.paid',
    //   data: {
    //     billing: { id, externalId, amount, status },
    //     customer: { id, name, email, taxId }
    //   }
    // }
    const customerId: string | undefined = body?.data?.customer?.id
    const billingId: string | undefined = body?.data?.billing?.id
    // externalId is the user.id we set when creating the checkout
    const externalUserId: string | undefined = body?.data?.billing?.externalId
    const paidAmount: number = body?.data?.billing?.amount ?? 3990

    if (!customerId && !externalUserId) {
      console.error('abacatepay-webhook: no customer or externalId in payload', body)
      return new Response(JSON.stringify({ error: 'identifier missing' }), { status: 400 })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // Find profile — prefer externalId (our user.id), fallback to abacatepay_customer_id
    let profileId: string | undefined

    if (externalUserId) {
      const { data } = await supabase
        .from('profiles')
        .select('id')
        .eq('id', externalUserId)
        .maybeSingle()
      profileId = data?.id
    }

    if (!profileId && customerId) {
      const { data } = await supabase
        .from('profiles')
        .select('id')
        .eq('abacatepay_customer_id', customerId)
        .maybeSingle()
      profileId = data?.id
    }

    if (!profileId) {
      console.error('abacatepay-webhook: profile not found', { customerId, externalUserId })
      return new Response(JSON.stringify({ error: 'profile not found' }), { status: 404 })
    }

    const now = new Date()
    const expiresAt = new Date(now)
    expiresAt.setMonth(expiresAt.getMonth() + 1)

    // Activate Pro for 1 month
    await supabase
      .from('profiles')
      .update({
        plan: 'pro',
        plan_activated_at: now.toISOString(),
        plan_expires_at: expiresAt.toISOString(),
      })
      .eq('id', profileId)

    // Update or insert subscription record
    if (billingId) {
      const { data: existing } = await supabase
        .from('subscriptions')
        .select('id')
        .eq('abacatepay_subscription_id', billingId)
        .maybeSingle()

      if (existing) {
        await supabase
          .from('subscriptions')
          .update({ status: 'active', amount_cents: paidAmount })
          .eq('id', existing.id)
      } else {
        await supabase.from('subscriptions').insert({
          owner_id: profileId,
          abacatepay_subscription_id: billingId,
          status: 'active',
          amount_cents: paidAmount,
        })
      }
    }

    console.log(`abacatepay-webhook: Pro activated for profile ${profileId}`)
    return new Response(JSON.stringify({ received: true }), { status: 200 })
  } catch (err) {
    console.error('abacatepay-webhook error', err)
    return new Response(JSON.stringify({ error: 'internal error' }), { status: 500 })
  }
})
