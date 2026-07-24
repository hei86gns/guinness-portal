-- ============================================================
-- v0.4.0: RLS(行レベルセキュリティ)を本格導入
-- 実行先: Supabase プロジェクト2(家族データ用 / Kakeiboと同居)
-- 実行方法: Supabase ダッシュボード → SQL Editor に貼り付けて Run
--
-- 前提: 事前に「家族専用アカウント」をダッシュボードで作成しておくこと
--   Authentication → Users → Add user
--   - Email: FAMILY_USER_EMAIL に設定するのと同じメールアドレス
--   - Auto Confirm User: チェックを入れる
--   - Password: ランダムな文字列を設定して、その後は使わずに忘れてよい
--     (このアカウントへのログインは verify-passphrase Function 経由のみに限定するため)
-- ============================================================

alter table shopping_items    enable row level security;
alter table pantry_items      enable row level security;
alter table subscriptions     enable row level security;
alter table car_reservations  enable row level security;
alter table events            enable row level security;

drop policy if exists "family only" on shopping_items;
create policy "family only" on shopping_items
  for all to authenticated using (true) with check (true);

drop policy if exists "family only" on pantry_items;
create policy "family only" on pantry_items
  for all to authenticated using (true) with check (true);

drop policy if exists "family only" on subscriptions;
create policy "family only" on subscriptions
  for all to authenticated using (true) with check (true);

drop policy if exists "family only" on car_reservations;
create policy "family only" on car_reservations
  for all to authenticated using (true) with check (true);

drop policy if exists "family only" on events;
create policy "family only" on events
  for all to authenticated using (true) with check (true);

-- 確認用: 各テーブルのRLSが有効になっているか一覧表示
select tablename, rowsecurity
from pg_tables
where schemaname = 'public'
  and tablename in ('shopping_items','pantry_items','subscriptions','car_reservations','events');
