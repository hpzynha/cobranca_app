import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
)

const PHONE_NUMBER_ID = Deno.env.get('WHATSAPP_PHONE_NUMBER_ID')!
const ACCESS_TOKEN = Deno.env.get('WHATSAPP_ACCESS_TOKEN')!

function normalizePhone(raw: string): string {
  const digits = raw.replace(/\D/g, '')
  if (digits.startsWith('55') && (digits.length === 12 || digits.length === 13)) return digits
  if (digits.length === 10 || digits.length === 11) return `55${digits}`
  return digits
}

function formatDateBR(isoDate: string): string {
  const part = isoDate.split('T')[0] // "2026-04-02"
  const [y, m, d] = part.split('-')
  return `${d}/${m}/${y}`
}

function formatValue(cents: number): string {
  const reais = cents / 100
  if (reais === Math.floor(reais)) return String(Math.floor(reais))
  return reais.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

async function sendTemplate(to: string, templateName: string, params: string[]): Promise<void> {
  const url = `https://graph.facebook.com/v19.0/${PHONE_NUMBER_ID}/messages`
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${ACCESS_TOKEN}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      messaging_product: 'whatsapp',
      to,
      type: 'template',
      template: {
        name: templateName,
        language: { code: 'pt_BR' },
        components: [
          {
            type: 'body',
            parameters: params.map((text) => ({ type: 'text', text })),
          },
        ],
      },
    }),
  })
  const json = await res.json()
  if (!res.ok) throw new Error(`WA API ${res.status}: ${JSON.stringify(json)}`)
  console.log(`Sent ${templateName} to ${to}:`, JSON.stringify(json))
}

Deno.serve(async () => {
  try {
    const todayUTC = new Date()
    const todayStr = todayUTC.toISOString().split('T')[0] // "2026-04-02" in UTC (= BRT at 08:00)

    // 1. Get all owners with profiles
    const { data: allProfiles, error: profilesError } = await supabase
      .from('profiles')
      .select('id, plan, pix_key, service_type, service_custom')

    if (profilesError) throw profilesError
    if (!allProfiles || allProfiles.length === 0) {
      return new Response(JSON.stringify({ sent: 0, message: 'No owners' }), { status: 200 })
    }

    const profileMap = new Map(allProfiles.map((p) => [p.id, p]))
    const allOwnerIds = allProfiles.map((p) => p.id)

    // 2. Get active students from all owners with WhatsApp
    const { data: students, error: studentsError } = await supabase
      .from('students')
      .select('id, owner_id, name, whatsapp, monthly_fee_cents, next_due_date')
      .eq('is_active', true)
      .in('owner_id', allOwnerIds)
      .not('whatsapp', 'is', null)
      .neq('whatsapp', '')
      .not('next_due_date', 'is', null)

    if (studentsError) throw studentsError

    // 3. Cache owner names
    const ownerNames = new Map<string, string>()

    const monthStart = todayStr.slice(0, 7) + '-01' // "2026-04-01"
    const nextMonthDate = new Date(todayStr + 'T00:00:00Z')
    nextMonthDate.setUTCMonth(nextMonthDate.getUTCMonth() + 1, 1)
    const monthEnd = nextMonthDate.toISOString().split('T')[0]

    let sent = 0
    let skipped = 0
    let errors = 0

    for (const student of students ?? []) {
      // Calculate days until due
      const nextDueStr = student.next_due_date.split('T')[0]
      const todayMs = new Date(todayStr + 'T00:00:00Z').getTime()
      const dueMs = new Date(nextDueStr + 'T00:00:00Z').getTime()
      const diffDays = Math.round((dueMs - todayMs) / (1000 * 60 * 60 * 24))

      const ownerPlan = (profileMap.get(student.owner_id) as any)?.plan ?? 'free'
      const isPro = ownerPlan === 'pro'

      // Free: only send on due date (diffDays === 0)
      // Pro: 3 days before, due today, or overdue (up to 30 days)
      if (isPro) {
        if (diffDays > 3 || (diffDays > 0 && diffDays < 3) || diffDays < -30) {
          skipped++
          continue
        }
      } else {
        if (diffDays !== 0) {
          skipped++
          continue
        }
      }

      // Skip if already paid this month
      const { count } = await supabase
        .from('payments')
        .select('id', { count: 'exact', head: true })
        .eq('student_id', student.id)
        .gte('competence_date', monthStart)
        .lt('competence_date', monthEnd)

      if ((count ?? 0) > 0) {
        skipped++
        continue
      }

      // Get owner name (cached)
      if (!ownerNames.has(student.owner_id)) {
        const { data: { user } } = await supabase.auth.admin.getUserById(student.owner_id)
        const ownerName = (user?.user_metadata?.full_name as string | undefined)
          || user?.email?.split('@')[0]
          || 'Professor'
        ownerNames.set(student.owner_id, ownerName)
      }
      const ownerName = ownerNames.get(student.owner_id)!

      const profile = profileMap.get(student.owner_id)! as { id: string; pix_key?: string | null; service_type?: string | null; service_custom?: string | null }
      const hasPix = !!(profile.pix_key?.trim())
      const service = profile.service_type === 'Outro'
        ? (profile.service_custom || 'Serviço')
        : (profile.service_type || 'Serviço')
      const valor = formatValue(student.monthly_fee_cents)
      const phone = normalizePhone(student.whatsapp)
      const dueDateBR = formatDateBR(student.next_due_date)

      try {
        let templateName = ''
        if (diffDays === 3) {
          templateName = hasPix ? 'lembrete_vencimento_pix' : 'lembrete_vencimento'
          if (hasPix) {
            await sendTemplate(phone, templateName, [
              student.name, service, ownerName, valor, '3', dueDateBR, profile.pix_key!,
            ])
          } else {
            await sendTemplate(phone, templateName, [
              student.name, service, ownerName, valor, '3', dueDateBR,
            ])
          }
        } else if (diffDays === 0) {
          templateName = hasPix ? 'vencimento_hoje_pix' : 'vencimento_hoje'
          if (hasPix) {
            await sendTemplate(phone, templateName, [
              student.name, service, ownerName, valor, profile.pix_key!,
            ])
          } else {
            await sendTemplate(phone, templateName, [
              student.name, service, ownerName, valor,
            ])
          }
        } else if (diffDays < 0) {
          templateName = hasPix ? 'cobranca_atrasada_pix' : 'cobranca_atrasada'
          if (hasPix) {
            await sendTemplate(phone, templateName, [
              student.name, service, ownerName, valor, dueDateBR, profile.pix_key!,
            ])
          } else {
            await sendTemplate(phone, templateName, [
              student.name, service, ownerName, valor, dueDateBR,
            ])
          }
        }
        try {
          await supabase.from('message_logs').insert({
            owner_id: student.owner_id,
            student_id: student.id,
            student_name: student.name,
            template: templateName,
            status: 'sent',
          })
        } catch (logErr) {
          console.error(`Failed to log sent message for student ${student.id}:`, logErr)
        }
        sent++
      } catch (err) {
        console.error(`Error for student ${student.id} (${student.name}):`, err)
        try {
          await supabase.from('message_logs').insert({
            owner_id: student.owner_id,
            student_id: student.id,
            student_name: student.name,
            template: 'unknown',
            status: 'failed',
            error_msg: String(err),
          })
        } catch (logErr) {
          console.error(`Failed to log failed message for student ${student.id}:`, logErr)
        }
        errors++
      }
    }

    console.log(`Done: sent=${sent}, skipped=${skipped}, errors=${errors}`)
    return new Response(JSON.stringify({ sent, skipped, errors }), { status: 200 })
  } catch (err) {
    console.error('Fatal error:', err)
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 })
  }
})
