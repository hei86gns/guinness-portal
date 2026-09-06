-- ============================================================
-- v0.8.0: アプリ台帳を「対照表」として使えるように項目を拡張
-- 目的: どのアプリがどのSupabaseプロジェクト／どのGitHubリポジトリかを
--       一目で分かるようにし、SQLの貼り間違いなどの事故を防ぐ。
-- 実行先: Supabase プロジェクトB（家族共有・Supabase上の表示名は「Kakeibo」
--         参照ID: zkqvqztadbzqwdwqhyjw）
-- 実行方法: Supabase ダッシュボード → SQL Editor に貼り付けて Run
-- ============================================================

-- 1. 項目を追加（何度実行しても安全）
alter table public.app_ledger add column if not exists repo          text;
alter table public.app_ledger add column if not exists project_label text;
alter table public.app_ledger add column if not exists project_ref   text;
alter table public.app_ledger add column if not exists db_tables     text;
alter table public.app_ledger add column if not exists hosting       text;
alter table public.app_ledger add column if not exists hosting_url   text;
alter table public.app_ledger add column if not exists stack         text;

-- 2. 中身を最新の実態に入れ替え（参照用データなので全入れ替えでよい）
delete from public.app_ledger;

insert into public.app_ledger
  (sort_order, icon, name, backend, project_label, project_ref, repo, db_tables, stack, hosting, hosting_url, rows, is_new, updated_at)
values
-- ===== プロジェクトA（個人用 / disfgytjjflnlowywess）=====
(1, '📖', 'tangocho（単語帳）', 'cloud',
 'A（個人用）', 'disfgytjjflnlowywess', 'hei86gns/tangocho',
 'user_data', '単一HTML', 'GitHub Pages', 'https://hei86gns.github.io/tangocho/',
 '[{"label":"ログイン","value":"個人アカウント（メール+パスワード）。アプリ内の新規登録画面から本人が追加できる"},{"label":"注意","value":"Workout_Appと同じuser_dataテーブルを共有している（列が違うので混ざらない）"}]'::jsonb,
 false, '2026-08-30'),

(2, '🏋️', 'Workout_App（筋トレ記録）', 'cloud',
 'A（個人用）', 'disfgytjjflnlowywess', 'hei86gns/Workout_App',
 'user_data', '単一HTML', 'GitHub Pages', 'https://hei86gns.github.io/Workout_App/',
 '[{"label":"ログイン","value":"個人アカウント（任意）。ログインせずローカルのみでも使える。アプリ内で新規登録可"},{"label":"注意","value":"tangochoと同じuser_dataテーブルを共有している"}]'::jsonb,
 false, '2026-09-06'),

(3, '✓', 'ToDo_App（タスク管理）', 'cloud',
 'A（個人用）', 'disfgytjjflnlowywess', '（GitHub未使用）',
 'todo_tasks / todo_push_subscriptions', 'PWA（単一HTML+SW）', 'Netlify', 'https://hei86gns-todo.netlify.app/',
 '[{"label":"ログイン","value":"個人アカウント（メール+パスワード）。アプリ内の新規登録から追加可"},{"label":"通知","value":"Web Push。Edge Function send-remindersをpg_cronで定期実行"},{"label":"注意","value":"GitHubを使っていない唯一のアプリ。更新はNetlifyへ直接反映"}]'::jsonb,
 false, '2026-09-02'),

(4, '🍽️', 'Restaurants_App（お店リスト）', 'cloud',
 'A（個人用）', 'disfgytjjflnlowywess', 'hei86gns/restaurants-app',
 'restaurants（写真はstorageのrestaurant_photos）', 'Next.js + React', 'Vercel', 'https://restaurants-app-five.vercel.app',
 '[{"label":"ログイン","value":"個人アカウント。RLSは本人の行のみ（_own系ポリシー）"},{"label":"注意","value":"公開先が唯一Vercel（他はGitHub PagesかNetlify）。ローカル開発時はhttp://localhost:3000"},{"label":"技術","value":"唯一のNext.js製。他アプリとは構成が異なる"}]'::jsonb,
 true, '2026-09-06'),

-- ===== プロジェクトB（家族共有 / zkqvqztadbzqwdwqhyjw、Supabase上の表示名は「Kakeibo」）=====
(5, '🏠', 'ギネス家ポータル（このアプリ）', 'cloud',
 'B（家族共有）', 'zkqvqztadbzqwdwqhyjw', 'hei86gns/guinness-portal',
 'shopping_items / pantry_items / subscriptions / car_reservations / events / links / app_ledger', '単一HTML', 'GitHub Pages', 'https://hei86gns.github.io/guinness-portal/',
 '[{"label":"ログイン","value":"家族共通の合言葉。Edge Functionでサーバー側照合→RLSで保護（個人アカウントの概念なし）"},{"label":"注意","value":"この台帳画面もapp_ledgerテーブルから読んでいる"}]'::jsonb,
 false, '2026-08-31'),

(6, '💰', 'Kakeibo_App（家計簿）', 'cloud',
 'B（家族共有）', 'zkqvqztadbzqwdwqhyjw', 'hei86gns/Kakeibo-app',
 'kakeibo_entries / kakeibo_settings', 'React + TypeScript（Vite）', 'GitHub Pages', 'https://hei86gns.github.io/Kakeibo-app/',
 '[{"label":"ログイン","value":"個人アカウント（招待制）。新規登録画面はなく、Supabase管理画面の「Invite user」で招待する"},{"label":"データ","value":"2026-08-28よりSupabase本体に保存。複数端末で同期される"}]'::jsonb,
 false, '2026-08-28'),

(7, '❤️', 'HealthDashboard（健康管理）', 'cloud',
 'B（家族共有）', 'zkqvqztadbzqwdwqhyjw', 'hei86gns/health-dashboard',
 'health_metrics / body_composition', '単一HTML', 'GitHub Pages', 'https://hei86gns.github.io/health-dashboard/',
 '[{"label":"ログイン","value":"個人アカウント。アプリ内に新規登録画面はなく、Supabase管理画面での手動作成が必要"},{"label":"取り込み","value":"iPhoneで手動書き出し→Macのlaunchdが検知して自動アップロード"},{"label":"注意","value":"閲覧は本人のみだが、取り込み（INSERT）はanon許可のまま"}]'::jsonb,
 false, '2026-09-06'),

-- ===== Supabaseを使っていないアプリ =====
(8, '📘', 'TOEIC_app（ゆりあTOEIC）', 'local',
 '（未使用）', null, 'hei86gns/toeic-app',
 '（なし）', '単一HTML', 'GitHub Pages', 'https://hei86gns.github.io/toeic-app/',
 '[{"label":"ログイン","value":"なし。ゆりあ専用アプリで、ユーザーという概念自体がない"},{"label":"データ","value":"すべてブラウザ内（localStorage）とHTML内の埋め込みデータ"},{"label":"注意","value":"本体はyuliaToeic_v1.html。index.htmlとyuriaToeic_v1.htmlは転送用スタブ"}]'::jsonb,
 false, '2026-07-31'),

(9, '📦', 'ContentManager（コンテンツ管理）', 'local',
 '（未使用）', null, '（GitHub未使用）',
 '（なし）', '単一HTML', '未公開', 'ローカルのみ',
 '[{"label":"状態","value":"試作のまま止まっている（2026-07-26以降さわっていない）"},{"label":"データ","value":"ローカルのみ。Supabase・GitHubいずれも未使用"}]'::jsonb,
 false, '2026-07-26');

-- 確認用：
--   select sort_order, name, project_label, repo, db_tables from public.app_ledger order by sort_order;
