-- ============================================================
-- v0.9.5: 新しいアプリ「photo-app（フォト）」を台帳に追加
--
-- 【なぜ必要か】
-- 2026-11-22 に、NAS の写真・動画を見るアプリを作った。
-- Supabase も GitHub も使わず、自宅の NAS（Synology DS224+）の中だけで動く初めてのアプリ。
-- Supabase 未使用のグループとして ContentManager の直前(10)に置き、ContentManager を 11 に下げる。
-- あわせて、前回追加した kiroku-app の NEW 表示を外す。
--
-- 実行先: Supabase プロジェクトB（家族共有・Supabase上の表示名は「Kakeibo」
--         参照ID: zkqvqztadbzqwdwqhyjw）
-- 実行方法: Supabase ダッシュボード → SQL Editor に貼り付けて Run
-- 何度実行しても結果は同じ（フォトの行は消してから入れ直す）。
-- ============================================================

-- ▼ 並び順: ContentManager を後ろへ
update public.app_ledger set sort_order = 11 where name like 'ContentManager%';

-- ▼ 前回の新着(kiroku-app)の NEW を外す
update public.app_ledger set is_new = false where name like 'kiroku-app%';

-- ▼ フォトの行（入れ直し）
delete from public.app_ledger where name like 'photo-app%';

insert into public.app_ledger
  (sort_order, icon, name, backend, project_label, project_ref, repo, db_tables, stack, hosting, hosting_url, rows, is_new, updated_at)
values
(10, '📷', 'photo-app（フォト）', 'local',
 '（未使用）', null, '（GitHub未使用）',
 'SQLite（NASの中）', 'Python（FastAPI）+ SQLite・Docker・PWA', 'Synology NAS（Tailscale経由）', 'https://norids224plus.tail8b4635.ts.net',
 '[{"label":"ログイン","value":"必須。一人ずつのアカウント。管理者（のり）が設定画面で作って初期パスワードを渡す→初回ログインでパスキー（Face IDなど）の登録が必須。登録後はパスワード不要"},{"label":"見るには","value":"端末にTailscaleアプリを入れてログインしておく必要がある（入れれば家の外からも見られる）。上の公開先リンクもTailscaleが無い端末では開けない"},{"label":"機能","value":"NASの写真・動画（約9.5万件）を撮影日順に表示。表示するフォルダの選択、見られる人を限定するフォルダ、メモ、星、検索（キーワード・場所・カメラ）、共有（JPEGに変換。位置情報は毎回選ぶ）"},{"label":"データ","value":"元の写真は読み取り専用で一切変更しない。写真や位置情報は外部に送らない（地名への変換もNASの中で行う）"},{"label":"作業中","value":"写っているもの（犬・カラスなど）で探すAI検索。モデルは作成済み、NASへの組み込みはこれから"},{"label":"注意","value":"Supabase・GitHubどちらも使っていない。てり・ゆりあはまだパスキー未登録（家族の端末にもTailscaleが必要）"}]'::jsonb,
 true, '2026-11-23');

-- 確認用：
--   select sort_order, name, backend, hosting, is_new, updated_at from public.app_ledger order by sort_order;
