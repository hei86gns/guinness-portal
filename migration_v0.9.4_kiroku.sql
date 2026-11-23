-- ============================================================
-- v0.9.4: 新しいアプリ「kiroku-app（記録アプリ）」を台帳に追加
--
-- 【なぜ必要か】
-- 2026-11 に記録アプリ（レシピ・買ったもの・読書記録など）を公開した。
-- プロジェクトB（家族共有）を使うアプリなので、B のグループ（6〜8）の直後(9)に置き、
-- ContentManager を 10 に下げる。
--
-- 実行先: Supabase プロジェクトB（家族共有・Supabase上の表示名は「Kakeibo」
--         参照ID: zkqvqztadbzqwdwqhyjw）
-- 実行方法: Supabase ダッシュボード → SQL Editor に貼り付けて Run
-- 何度実行しても結果は同じ（記録アプリの行は消してから入れ直す）。
-- ============================================================

-- ▼ 並び順: ContentManager を後ろへ
update public.app_ledger set sort_order = 10 where name like 'ContentManager%';

-- ▼ 記録アプリの行（入れ直し）
delete from public.app_ledger where name like 'kiroku-app%';

insert into public.app_ledger
  (sort_order, icon, name, backend, project_label, project_ref, repo, db_tables, stack, hosting, hosting_url, rows, is_new, updated_at)
values
(9, '📚', 'kiroku-app（記録アプリ）', 'cloud',
 'B（家族共有）', 'zkqvqztadbzqwdwqhyjw', 'hei86gns/kiroku-app',
 'kiroku_collections / kiroku_records（写真はstorageのkiroku-photos・非公開）', 'React + TypeScript（Vite）・PWA', 'GitHub Pages', 'https://hei86gns.github.io/kiroku-app/',
 '[{"label":"ログイン","value":"必須。メール+パスワード（Kakeiboと同じ招待制。新規登録画面なし）"},{"label":"機能","value":"レシピ・買ったもの・読書記録などを写真つきで記録。コレクションは設定から追加できる。ホーム画面に追加でき、電波がなくても登録→つながったら自動送信"},{"label":"データ","value":"2026-11-04にNotionから583件を取り込み済み。写真は非公開バケットに保存し、期限つきURLで表示"},{"label":"注意","value":"iPhone実機での確認はまだ。Kakeiboと同じプロジェクトBなので、SQLはBに貼る"}]'::jsonb,
 true, '2026-11-05');

-- 確認用：
--   select sort_order, name, project_label, db_tables, updated_at from public.app_ledger order by sort_order;
