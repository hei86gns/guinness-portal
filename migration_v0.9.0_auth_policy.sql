-- ============================================================
-- v0.9.0: アカウント(ログイン)まわりの記載を実態に合わせて修正
--
-- 【なぜ必要か】
-- これまでの台帳には「アプリ内の新規登録から本人が追加できる」と書いていたが、
-- 2026-09-07にSupabaseの設定を実地確認したところ、事実と違っていた。
--   ・プロジェクトA は新規登録が禁止(disable_signup: true)
--   ・メール確認が必須(mailer_autoconfirm: false)だが、無料枠ではメールが届かない
--   → よってAのアカウントは「管理者がSupabase画面で作る」しかない。
--
-- 実行先: Supabase プロジェクトB（家族共有・Supabase上の表示名は「Kakeibo」
--         参照ID: zkqvqztadbzqwdwqhyjw）
--         ※台帳データの置き場所がBというだけで、内容はAの話。混同しないこと。
-- 実行方法: Supabase ダッシュボード → SQL Editor に貼り付けて Run
-- ============================================================

-- ▼ プロジェクトA の4アプリ：アカウントは共通、新規登録は禁止

update public.app_ledger set
  rows = '[{"label":"ログイン","value":"任意。ログインしなくても全機能を使える(データはその端末のブラウザ内)。複数端末で同期したい人だけログインする"},{"label":"アカウント","value":"プロジェクトA共通。1組のID/パスワードで筋トレ・ToDo・お店リストにもログインできる。新規登録は禁止されているため、管理者がSupabaseのCreate new user(☑Auto Confirm User)で作成する"},{"label":"注意","value":"Workout_Appと同じuser_dataテーブルを共有している(列が違うので混ざらない)"}]'::jsonb,
  updated_at = '2026-09-07'
where name like 'tangocho%';

update public.app_ledger set
  rows = '[{"label":"ログイン","value":"任意。ログインしなければ端末内だけで使える"},{"label":"アカウント","value":"プロジェクトA共通。新規登録は禁止されているため、管理者がSupabaseのCreate new user(☑Auto Confirm User)で作成する"},{"label":"注意","value":"tangochoと同じuser_dataテーブルを共有している"}]'::jsonb,
  updated_at = '2026-09-07'
where name like 'Workout_App%';

update public.app_ledger set
  rows = '[{"label":"ログイン","value":"必須。メールアドレス+パスワード"},{"label":"アカウント","value":"プロジェクトA共通。管理者がSupabaseのCreate new user(☑Auto Confirm User)で作成する"},{"label":"注意","value":"画面に「新規登録」ボタンがあるが、新規登録が禁止されているため押しても失敗する(表示と設定が食い違っている)"},{"label":"通知","value":"Web Push。Edge Function send-remindersをpg_cronで定期実行"},{"label":"注意","value":"GitHubを使っていない唯一のアプリ。更新はNetlifyへ直接反映"}]'::jsonb,
  updated_at = '2026-09-07'
where name like 'ToDo_App%';

update public.app_ledger set
  rows = '[{"label":"ログイン","value":"必須。メールアドレス+パスワード"},{"label":"アカウント","value":"プロジェクトA共通。管理者がSupabaseのCreate new user(☑Auto Confirm User)で作成し、パスワードまで決めて本人に伝える"},{"label":"注意","value":"「パスワードを忘れた・まだ設定していない方」のコード認証はメールが届かないため使えない"},{"label":"注意","value":"公開先が唯一Vercel。ローカル開発時はhttp://localhost:3000"},{"label":"技術","value":"唯一のNext.js製。写真はstorageのrestaurant_photosに保存"}]'::jsonb,
  updated_at = '2026-09-07'
where name like 'Restaurants_App%';

-- 確認用：
--   select name, project_label, updated_at from public.app_ledger order by sort_order;
