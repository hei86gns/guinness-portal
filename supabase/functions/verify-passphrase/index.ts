// 合言葉をサーバー側だけで照合し、正しければ「家族専用アカウント」の
// ログイン済みセッションを発行して返す。合言葉そのものはこの関数の外(ブラウザ側)
// には一切送らない。誰でも読めるHTMLソースにハッシュを置かないための仕組み。
import { createClient } from 'npm:@supabase/supabase-js@2'

const PASSPHRASE_HASH = Deno.env.get('PASSPHRASE_HASH')!
const FAMILY_USER_EMAIL = Deno.env.get('FAMILY_USER_EMAIL')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY)

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

async function sha256Hex(text: string): Promise<string> {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text))
  return [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, '0')).join('')
}

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  })
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS })

  try {
    const { passphrase } = await req.json()
    if (typeof passphrase !== 'string' || !passphrase) {
      return json({ error: '合言葉を入力してください' }, 400)
    }

    const hash = await sha256Hex(passphrase)
    if (hash !== PASSPHRASE_HASH) {
      return json({ error: '合言葉がちがいます' }, 401)
    }

    // 合言葉が正しいときだけ、家族専用アカウントのセッションを発行する
    const { data: link, error: linkErr } = await admin.auth.admin.generateLink({
      type: 'magiclink',
      email: FAMILY_USER_EMAIL,
    })
    if (linkErr || !link) throw linkErr ?? new Error('link generation failed')

    const { data: verified, error: verifyErr } = await admin.auth.verifyOtp({
      type: 'magiclink',
      token_hash: link.properties.hashed_token,
    })
    if (verifyErr || !verified.session) throw verifyErr ?? new Error('session verify failed')

    return json({
      access_token: verified.session.access_token,
      refresh_token: verified.session.refresh_token,
    }, 200)
  } catch (e) {
    console.error(e)
    return json({ error: 'サーバーエラーが発生しました' }, 500)
  }
})
