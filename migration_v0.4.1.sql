-- ============================================================
-- v0.4.1 マイグレーション: リンク&メモ機能の追加
-- 実行先: Supabase プロジェクト2 → SQL Editor に貼り付けて Run
-- 前提: v0.4.0（RLS導入・migration_v0.4.0_rls.sql）まで適用済みであること
-- 既存データには触れません（新しいテーブルを1つ作るだけ）
-- ============================================================
create table if not exists links (
  id uuid primary key default gen_random_uuid(),
  icon text not null default '🔗',
  title text not null,
  url text not null,
  note text,
  created_at timestamptz not null default now()
);

-- 他テーブルと同じ「認証済みユーザーのみ」ポリシーをそろえる
alter table links enable row level security;
drop policy if exists "family only" on links;
create policy "family only" on links
  for all to authenticated using (true) with check (true);

alter publication supabase_realtime add table links;
