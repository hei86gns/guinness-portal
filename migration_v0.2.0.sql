-- ============================================================
-- v0.2.0 マイグレーション: カレンダー予定の期間対応
-- 実行先: Supabase プロジェクト2 → SQL Editor に貼り付けて Run
-- 内容: events テーブルに「終了日」「終了時刻」の列を追加
--（既存の予定データはそのまま。単日予定として扱われます）
-- ============================================================
alter table events add column if not exists end_date date;
alter table events add column if not exists end_time time;
