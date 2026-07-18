-- ============================================================
-- v0.3.0 マイグレーション: 家族の要望リスト対応
-- 実行先: Supabase プロジェクト2 → SQL Editor に貼り付けて Run
-- 既存データはそのまま残ります
-- ============================================================

-- 【在庫】品目カテゴリ（野菜/調味料/...）・備考欄・よく使う回数
alter table pantry_items add column if not exists item_category text not null default 'その他';
alter table pantry_items add column if not exists note text;
alter table pantry_items add column if not exists use_count integer not null default 1;

-- 【買い物】「切れた→買う→在庫に戻す」の循環で在庫の情報を持ち回るための列
alter table shopping_items add column if not exists pantry_item_category text;
alter table shopping_items add column if not exists pantry_note text;
alter table shopping_items add column if not exists pantry_use_count integer;

-- 【予定】複数メンバー（「みんな」含む）・食事不要（朝/昼/夜）
alter table events add column if not exists members text[];
update events set members = array[member] where members is null and member is not null;
alter table events alter column member drop not null;
alter table events add column if not exists skip_meals text[];
