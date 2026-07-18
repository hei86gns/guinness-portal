-- ============================================================
-- ギネス家ポータル DBセットアップ
-- 実行先: Supabase プロジェクト2（家族データ用 / Kakeiboと同居）
-- 実行方法: Supabase ダッシュボード → SQL Editor に貼り付けて Run
-- ============================================================

-- 車予約の重複防止（時間範囲の排他制約）に必要な拡張
create extension if not exists btree_gist;

-- ------------------------------------------------------------
-- 1. 買い物リスト
-- source: 'manual' = 手で追加 / 'pantry' = 食材在庫の「切れた」から自動追加
-- pantry_category: 在庫由来の品目が購入された時、在庫に戻す際のカテゴリを覚えておく
-- ------------------------------------------------------------
create table if not exists shopping_items (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  checked boolean not null default false,
  source text not null default 'manual' check (source in ('manual', 'pantry')),
  pantry_category text,       -- 在庫に戻す際の保管場所（冷蔵/冷凍/常温）
  pantry_item_category text,  -- 在庫に戻す際の品目カテゴリ（野菜/調味料/...）
  pantry_note text,           -- 在庫に戻す際の備考
  pantry_use_count integer,   -- 在庫に戻す際に引き継ぐ使用回数
  created_at timestamptz not null default now(),
  checked_at timestamptz
);

-- ------------------------------------------------------------
-- 2. 食材在庫（品名＋賞味期限のみ。入力の手間を最小化）
-- ------------------------------------------------------------
create table if not exists pantry_items (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null default '冷蔵' check (category in ('冷蔵', '冷凍', '常温')),
  item_category text not null default 'その他',  -- 野菜/調味料/主食/飲料/肉魚類/果物/缶詰/お菓子/生活消耗品/その他
  expires_on date not null,
  note text,                                     -- 備考（フリーテキスト）
  use_count integer not null default 1,          -- 「よく使う順」ソート用
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 3. サブスクリスト
-- cycle: 'monthly'（月額）/ 'yearly'（年額。月額換算は amount/12）
-- renewal_month: 更新月（1-12）。年払いの更新通知に使用
-- ※ 将来 Kakeibo と支出連携する場合は、Kakeibo 側のカテゴリ名を
--    note に入れるか、category 列を後から追加すればよいスキーマにしてある
-- ------------------------------------------------------------
create table if not exists subscriptions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  amount integer not null check (amount >= 0),
  cycle text not null default 'monthly' check (cycle in ('monthly', 'yearly')),
  renewal_month integer check (renewal_month between 1 and 12),
  note text,
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 4. 車予約
-- 重複予約はUI側チェック＋この排他制約の二段構えで防止
-- （時間帯が重なる予約はDBが拒否する。エラーコード 23P01）
-- ------------------------------------------------------------
create table if not exists car_reservations (
  id uuid primary key default gen_random_uuid(),
  member text not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  note text,
  created_at timestamptz not null default now(),
  check (ends_at > starts_at),
  constraint no_overlap exclude using gist (tstzrange(starts_at, ends_at) with &&)
);

-- ------------------------------------------------------------
-- 5. カレンダー（ホーム画面の「今日の予定」もこのテーブルを流用）
-- ------------------------------------------------------------
create table if not exists events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  member text,                 -- 旧形式（v0.3.0以降は members を使用）
  members text[],              -- 参加メンバー（複数可。'みんな' も可）
  event_date date not null,    -- 開始日
  end_date date,               -- 終了日（nullなら単日の予定）
  start_time time,             -- 開始時刻（nullなら終日）
  end_time time,               -- 終了時刻
  skip_meals text[],           -- 食事不要（'朝','昼','夜' の組み合わせ）
  note text,
  created_at timestamptz not null default now()
);
create index if not exists idx_events_date on events (event_date);

-- ------------------------------------------------------------
-- Realtime 有効化（家族間のリアルタイム同期。二重買い防止の要）
-- ------------------------------------------------------------
alter publication supabase_realtime add table shopping_items;
alter publication supabase_realtime add table pantry_items;
alter publication supabase_realtime add table subscriptions;
alter publication supabase_realtime add table car_reservations;
alter publication supabase_realtime add table events;

-- ============================================================
-- （任意）RLS を有効にしたくなったら以下を実行
-- 合言葉方式のままでは anon キーで全操作可能なため、
-- 本格的に守るなら Supabase Auth 導入とセットで行うこと。
-- ============================================================
-- alter table shopping_items enable row level security;
-- alter table pantry_items enable row level security;
-- alter table subscriptions enable row level security;
-- alter table car_reservations enable row level security;
-- alter table events enable row level security;
-- create policy "family only" on shopping_items for all to authenticated using (true) with check (true);
-- （他テーブルも同様）
