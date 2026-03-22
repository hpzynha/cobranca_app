import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const FCM_PROJECT_ID = Deno.env.get("FCM_PROJECT_ID")!;
const GOOGLE_SERVICE_ACCOUNT_JSON = Deno.env.get("GOOGLE_SERVICE_ACCOUNT_JSON")!;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// ─── Google OAuth2 via Service Account ──────────────────────────────────────

async function getFcmAccessToken(): Promise<string> {
  const sa = JSON.parse(GOOGLE_SERVICE_ACCOUNT_JSON);
  const now = Math.floor(Date.now() / 1000);

  const header = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const encode = (obj: object) =>
    btoa(JSON.stringify(obj))
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=+$/, "");

  const headerB64 = encode(header);
  const payloadB64 = encode(payload);
  const signingInput = `${headerB64}.${payloadB64}`;

  // Import RSA private key
  const pemBody = sa.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\n/g, "");
  const keyDer = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    keyDer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signingInput),
  );

  const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");

  const jwt = `${signingInput}.${signatureB64}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const tokenData = await tokenRes.json();
  if (!tokenRes.ok) {
    throw new Error(`Failed to get FCM token: ${JSON.stringify(tokenData)}`);
  }

  return tokenData.access_token;
}

// ─── FCM Send ────────────────────────────────────────────────────────────────

async function sendFcmNotification(
  accessToken: string,
  fcmToken: string,
  title: string,
  body: string,
): Promise<void> {
  const url =
    `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`;

  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: {
        token: fcmToken,
        notification: { title, body },
      },
    }),
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`FCM error for token ${fcmToken.slice(0, 20)}…: ${err}`);
  }
}

// ─── Build notification message ───────────────────────────────────────────────

function buildMessage(
  overdueCount: number,
  dueSoonCount: number,
): { title: string; body: string } {
  if (overdueCount > 0 && dueSoonCount > 0) {
    return {
      title: "🔔 Atenção às cobranças",
      body: `${overdueCount} em atraso · ${dueSoonCount} vencem em breve`,
    };
  }
  if (overdueCount > 0) {
    return {
      title: "🔴 Pagamento atrasado",
      body: `${overdueCount} aluno(s) estão em atraso`,
    };
  }
  return {
    title: "⏰ Cobrança se aproximando",
    body: `${dueSoonCount} aluno(s) vencem em breve`,
  };
}

// ─── Main ─────────────────────────────────────────────────────────────────────

Deno.serve(async () => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // 1. Fetch all active students with overdue or due_soon status (global, service role)
    const { data: students, error: studentsError } = await supabase
      .from("students")
      .select("id, owner_id, next_due_date, monthly_fee_cents")
      .eq("is_active", true)
      .not("next_due_date", "is", null);

    if (studentsError) throw studentsError;

    // Classify per owner
    const ownerMap = new Map<
      string,
      { overdueCount: number; dueSoonCount: number }
    >();

    for (const student of students ?? []) {
      const nextDue = new Date(student.next_due_date);
      nextDue.setHours(0, 0, 0, 0);
      const diffDays = Math.floor(
        (nextDue.getTime() - today.getTime()) / (1000 * 60 * 60 * 24),
      );

      // Check if already paid this month
      const { count } = await supabase
        .from("payments")
        .select("id", { count: "exact", head: true })
        .eq("student_id", student.id)
        .gte(
          "competence_date",
          new Date(today.getFullYear(), today.getMonth(), 1)
            .toISOString()
            .split("T")[0],
        )
        .lt(
          "competence_date",
          new Date(today.getFullYear(), today.getMonth() + 1, 1)
            .toISOString()
            .split("T")[0],
        );

      if ((count ?? 0) > 0) continue; // already paid this month

      const entry = ownerMap.get(student.owner_id) ??
        { overdueCount: 0, dueSoonCount: 0 };

      if (diffDays < 0) {
        entry.overdueCount++;
      } else if (diffDays <= 2) {
        entry.dueSoonCount++;
      }

      ownerMap.set(student.owner_id, entry);
    }

    // Remove owners with no actionable students
    for (const [ownerId, counts] of ownerMap) {
      if (counts.overdueCount === 0 && counts.dueSoonCount === 0) {
        ownerMap.delete(ownerId);
      }
    }

    if (ownerMap.size === 0) {
      console.log("No owners with due/overdue students. Nothing to send.");
      return new Response(JSON.stringify({ sent: 0 }), { status: 200 });
    }

    // 2. Get FCM access token once
    const accessToken = await getFcmAccessToken();

    let totalSent = 0;
    let totalErrors = 0;

    // 3. For each owner, fetch tokens and send
    for (const [ownerId, counts] of ownerMap) {
      const { data: tokenRows, error: tokenError } = await supabase
        .from("fcm_tokens")
        .select("token")
        .eq("owner_id", ownerId);

      if (tokenError) {
        console.error(`Error fetching tokens for owner ${ownerId}:`, tokenError);
        continue;
      }

      if (!tokenRows || tokenRows.length === 0) continue;

      const { title, body } = buildMessage(
        counts.overdueCount,
        counts.dueSoonCount,
      );

      for (const row of tokenRows) {
        try {
          await sendFcmNotification(accessToken, row.token, title, body);
          console.log(`Sent to owner ${ownerId}, token …${row.token.slice(-8)}`);
          totalSent++;
        } catch (err) {
          console.error(`Failed for owner ${ownerId}:`, err);
          totalErrors++;
        }
      }
    }

    return new Response(
      JSON.stringify({ sent: totalSent, errors: totalErrors }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Unhandled error:", err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
