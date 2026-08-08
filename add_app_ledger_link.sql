-- ============================================================
-- マイアプリ台帳を「リンク&メモ」に登録する
-- 実行先: Supabase プロジェクトB → SQL Editor に貼り付けて Run
-- 内容: リンク1件(見やすいHTML版へのURL) + メモ1件(要約テキスト)
-- ============================================================

insert into links (icon, title, url, category, type)
values (
  '📒',
  'マイアプリ台帳(詳細版)',
  'https://claude.ai/code/artifact/ba5c04fa-e2d7-43c8-afa9-fbbcbb3ed598',
  '開発',
  'link'
);

insert into links (icon, title, note, category, type)
values (
  '📒',
  'マイアプリ台帳(要約)',
  $$自作アプリ6つ(tangocho / TOEIC_app / HealthDashboard / Kakeibo_App / Workout_App / ギネス家ポータル)の保存場所とSupabase構成のまとめ。クラウドDBは、tangochoとWorkout_Appが個人用のプロジェクトA、ギネス家ポータル・Kakeibo_App・HealthDashboardが家族共有のプロジェクトBを使用。TOEIC_appのみクラウド未使用でローカルファイルのみ。ユーザー追加は、tangochoとWorkout_Appはアプリ内の新規登録画面から本人が可能。HealthDashboardとKakeibo_Appはアプリ内に追加手段がなくSupabase管理画面での手動作成が必要。TOEIC_appとギネス家ポータルはユーザー追加の概念自体がない(TOEIC_appはゆりあ専用、ポータルは家族共通の合言葉)。詳細な表は「マイアプリ台帳(詳細版)」のリンクを開いて確認。最終更新2026-08-05。$$,
  '開発',
  'memo'
);
