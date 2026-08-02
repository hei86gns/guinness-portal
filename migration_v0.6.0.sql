-- ============================================================
-- v0.6.0 マイグレーション: 車予約の拡張(自転車対応)
-- 実行先: Supabase プロジェクト2 → SQL Editor に貼り付けて Run
-- 前提: v0.5.0まで適用済みであること
-- 既存の予約はすべて vehicle='車' として残ります
-- ============================================================

alter table car_reservations add column if not exists vehicle text not null default '車' check (vehicle in ('車', '自転車'));

-- 重複防止の排他制約を「同じ乗り物同士でのみ重複NG」に変更
-- (車と自転車は別物なので、同じ時間帯でも両方予約できるようにする)
alter table car_reservations drop constraint if exists no_overlap;
alter table car_reservations add constraint no_overlap
  exclude using gist (vehicle with =, tstzrange(starts_at, ends_at) with &&);
