-- ============================================================
-- v0.5.0 マイグレーション: リンク&メモの拡張
-- 実行先: Supabase プロジェクト2 → SQL Editor に貼り付けて Run
-- 前提: v0.4.1まで適用済みであること
-- 内容:
--   ・メモ単独保存(URL不要)に対応
--   ・カテゴリ(自由入力)を追加
--   ・写真/PDF添付用のストレージ(非公開バケット)を新設
-- 既存のリンクデータはそのまま type='link' として残ります
-- ============================================================

alter table links add column if not exists type text not null default 'link' check (type in ('link', 'memo'));
alter table links alter column url drop not null;
alter table links add column if not exists category text;
alter table links add column if not exists attachments jsonb not null default '[]'::jsonb;

-- 添付ファイル用ストレージバケット（非公開。合言葉でログインした家族のみアクセス可）
insert into storage.buckets (id, name, public)
values ('attachments', 'attachments', false)
on conflict (id) do nothing;

drop policy if exists "family only select" on storage.objects;
create policy "family only select" on storage.objects
  for select to authenticated using (bucket_id = 'attachments');

drop policy if exists "family only insert" on storage.objects;
create policy "family only insert" on storage.objects
  for insert to authenticated with check (bucket_id = 'attachments');

drop policy if exists "family only delete" on storage.objects;
create policy "family only delete" on storage.objects
  for delete to authenticated using (bucket_id = 'attachments');
