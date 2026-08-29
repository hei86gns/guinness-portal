-- ============================================================
-- v0.7.0: 「アプリ台帳」をSupabase駆動にする
-- これまではindex.html内に手書きしたスナップショットだったが、
-- app_ledgerテーブルから読み込む形にして、内容を更新すれば
-- ポータル側にも自動的に反映されるようにする。
-- 実行先: Supabase プロジェクトB（家族共有／Kakeiboと同居・zkqvqztadbzqwdwqhyjw）
-- 実行方法: Supabase ダッシュボード → SQL Editor に貼り付けて Run
-- ============================================================

create table if not exists public.app_ledger (
  id          bigint generated always as identity primary key,
  sort_order  int not null default 0,
  icon        text,
  name        text not null,
  backend     text not null default 'cloud' check (backend in ('cloud','local')),
  url         text,
  rows        jsonb not null default '[]'::jsonb,  -- [{"label":"ログイン","value":"..."}, ...]
  is_new      boolean not null default false,
  updated_at  date,
  created_at  timestamptz not null default now()
);

alter table public.app_ledger enable row level security;

drop policy if exists "family only" on public.app_ledger;
create policy "family only" on public.app_ledger
  for all to authenticated using (true) with check (true);

-- 他のテーブル同様、家族の全端末にリアルタイム反映されるようにする
alter publication supabase_realtime add table public.app_ledger;

-- ---------------------------------------------------------------------
-- 初期データ（既存の手書きスナップショットの内容 + 新しく増えたToDo_App）
-- ---------------------------------------------------------------------
insert into public.app_ledger (sort_order, icon, name, backend, url, rows, is_new, updated_at) values
(1, '📖', 'tangocho(単語帳)', 'cloud', null,
  '[{"label":"ログイン","value":"個人アカウント(メール+パスワード、アプリ内で新規登録可)"}]'::jsonb,
  false, '2026-07-04'),
(2, '📘', 'TOEIC_app(ゆりあTOEIC)', 'local', null,
  '[{"label":"ログイン","value":"なし(ゆりあ専用アプリ、ユーザーの概念自体がない)"}]'::jsonb,
  false, '2026-07-23'),
(3, '❤️', 'HealthDashboard', 'cloud', null,
  '[{"label":"ログイン","value":"個人アカウント。ただしアプリ内に新規登録画面はなく、Supabase管理画面での手動作成が必要"},{"label":"取り込み","value":"iPhoneで手動書き出し→Macが自動でアップロード"}]'::jsonb,
  false, '2026-07-25'),
(4, '💰', 'Kakeibo_App(家計簿)', 'cloud', null,
  '[{"label":"ログイン","value":"個人アカウント(招待制)。新規登録画面はなく、Supabase管理画面の「Invite user」で招待が必要"},{"label":"データ","value":"2026-08-28よりSupabase本体に保存され、複数端末で同期されるように"}]'::jsonb,
  false, '2026-08-28'),
(5, '🏋️', 'Workout_App(筋トレ記録)', 'cloud', null,
  '[{"label":"ログイン","value":"個人アカウント(任意。ログインせずローカルのみでも使える。アプリ内で新規登録可)"}]'::jsonb,
  false, '2026-06-28'),
(6, '🏠', 'ギネス家ポータル(このアプリ)', 'cloud', null,
  '[{"label":"ログイン","value":"なし(個人アカウントの概念がなく、家族共通の合言葉を共有する方式)"}]'::jsonb,
  false, '2026-07-25'),
(7, '✓', 'ToDo_App(タスク管理)', 'cloud', 'https://hei86gns-todo.netlify.app',
  '[{"label":"ログイン","value":"個人アカウント(メール+パスワード)。アプリ内の「新規登録」から追加可"},{"label":"通知","value":"締切の3日前・前日・1時間前にスマホへプッシュ通知(通知をオンにした端末のみ)"},{"label":"機能","value":"タスク追加/完了/削除・優先度・期日・繰り返し・端末間リアルタイム同期"}]'::jsonb,
  true, '2026-08-29');

-- 確認用：
--   select sort_order, name, backend, updated_at from public.app_ledger order by sort_order;
