-- ============================================================
-- v0.9.3: TOEIC_app（ゆりあTOEIC）がクラウド保存に対応したので台帳を更新
--
-- 【なぜ必要か】
-- 2026-09-22 に TOEIC_app がログイン任意のクラウド保存に対応し、
-- プロジェクトA（個人用）の toeic_data テーブルを使うようになった。
-- これまで台帳では「Supabase未使用・ローカルのみ」と書いていたため、実態に合わせる。
-- あわせて、並び順をプロジェクトAのアプリ（1〜4）のすぐ後ろ(5)に移す。
--
-- 実行先: Supabase プロジェクトB（家族共有・Supabase上の表示名は「Kakeibo」
--         参照ID: zkqvqztadbzqwdwqhyjw）
--         ※台帳データの置き場所がBというだけで、内容はAの話。混同しないこと。
-- 実行方法: Supabase ダッシュボード → SQL Editor に貼り付けて Run
-- 何度実行しても結果は同じ（並び順のずらしは1回目だけ行われる）。
-- ============================================================

-- ▼ 並び順: ポータル・家計簿・健康(5〜7)を1つずつ後ろへ（TOEICがまだ8番のときだけ）
update public.app_ledger set sort_order = sort_order + 1
where sort_order between 5 and 7
  and exists (select 1 from public.app_ledger where name like 'TOEIC_app%' and sort_order = 8);

-- ▼ TOEIC_app の中身
update public.app_ledger set
  sort_order    = 5,
  backend       = 'cloud',
  project_label = 'A（個人用）',
  project_ref   = 'disfgytjjflnlowywess',
  db_tables     = 'toeic_data',
  rows = '[{"label":"ログイン","value":"任意。ログインしなければ従来どおり端末内(localStorage)だけで使える。複数端末で同じ記録を使いたいときだけログインする"},{"label":"アカウント","value":"プロジェクトA共通。1組のID/パスワードで単語帳・筋トレ・ToDo・お店リストにもログインできる。新規登録は禁止されているため、管理者がSupabaseのCreate new user(☑Auto Confirm User)で作成する"},{"label":"データ","value":"toeic_dataテーブルに1人1行(アプリのデータをまるごとJSONで保存)。2台で食い違ったら新しく保存したほうを採用。user_dataとは別テーブルなので他アプリと混ざらない"},{"label":"注意","value":"本体はyuliaToeic_v1.html。index.htmlとyuriaToeic_v1.htmlは転送用スタブ"}]'::jsonb,
  updated_at    = '2026-09-22'
where name like 'TOEIC_app%';

-- 確認用：
--   select sort_order, name, backend, project_label, db_tables, updated_at from public.app_ledger order by sort_order;
