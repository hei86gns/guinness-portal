# ギネス家ポータル 🏠

家族で共有する生活ハブアプリ。予定・車・買い物・食材・サブスクの5機能を1つのポータルにまとめたもの。

- フロントエンド: **単一HTMLファイル**（index.html だけで動く）
- バックエンド: **Supabase プロジェクト2**（家族データ用・Kakeiboと同居）
- ホスティング: **GitHub Pages**

```
┌─────────────────────────────┐
│  🏠 ホーム（今日の予定 + バッジ）  │
├──────┬──────┬──────┬───────┤
│🛒買い物│🥚在庫 │💳ｻﾌﾞｽｸ│🚗車 📅暦│
└──────┴──────┴──────┴───────┘
        ↕ Supabase Realtime（家族の全スマホに即時同期）
┌─────────────────────────────┐
│ Supabase プロジェクト2（家族用）   │
│ shopping_items / pantry_items /  │
│ subscriptions / car_reservations │
│ / events （+ 既存のKakeibo）      │
└─────────────────────────────┘
```

## 初回セットアップ（3ステップ）

### 1. データベースを作る

Supabase ダッシュボード（**プロジェクト2** の方）→ SQL Editor →
`setup.sql` の中身を貼り付けて **Run**。

テーブル5つの作成・Realtime有効化・車予約の重複防止制約まで一括で入ります。

### 2. 家族メンバー名を書き換える

`index.html` の `CONFIG.MEMBERS` を実際の家族に合わせて編集（設定済み）：

```js
MEMBERS: [
  { name: 'のり', color: '#3b82f6' },   // 青
  { name: 'てり', color: '#ec4899' },   // ピンク
  { name: 'ゆりあ', color: '#10b981' }, // 緑
],
```

### 3. GitHub Pages に公開

```bash
gh repo create guinness-portal --private --source . --push
# → リポジトリの Settings → Pages → Branch: main / (root) を選択
```

スマホで開いて「ホーム画面に追加」すればアプリのように使えます。

## 合言葉について（v0.4.0〜: サーバー側で照合する方式に変更）

以前は合言葉のハッシュを `index.html` に直接書いていたため、GitHubが公開リポジトリの
場合は誰でもハッシュを読める＝オフラインで総当たりされ得る状態だった。v0.4.0からは
照合をSupabase Edge Function（`supabase/functions/verify-passphrase`）に移し、
ハッシュも合言葉も画面側のコードには一切置かない構成にした。

```
[今まで]  ブラウザが自分でハッシュを比較（HTML内にハッシュが見える）
[v0.4.0〜] ブラウザ → Edge Function にPOST → サーバー側だけで比較
              └─ 正解なら「家族専用アカウント」のログイン済みセッションを返す
              └─ このセッションでRLS（migration_v0.4.0_rls.sql）を通過できる
```

### 初回セットアップ（RLS導入時の追加ステップ）

1. **家族専用アカウントを作る**（1回だけ）
   Supabase ダッシュボード → Authentication → Users → **Add user**
   - Email: 任意（例 `family-portal@guinness.internal`。実在しなくてよい）
   - Auto Confirm User: ON
   - Password: ランダムな文字列を設定して、以後は使わず忘れてよい
     （このアカウントへのログインは Edge Function 経由のみに限定するため）

2. **RLSを有効化**
   `migration_v0.4.0_rls.sql` の中身を SQL Editor に貼り付けて Run。

3. **Edge Function をデプロイし、Secretsを設定**
   ```bash
   supabase login
   supabase link --project-ref zkqvqztadbzqwdwqhyjw
   supabase functions deploy verify-passphrase
   supabase secrets set \
     PASSPHRASE_HASH=<新しい合言葉のSHA-256ハッシュ> \
     FAMILY_USER_EMAIL=<手順1で作ったメールアドレス>
   ```
   合言葉のハッシュは以下で作成:
   ```bash
   printf '新しい合言葉' | shasum -a 256
   ```
   ⚠️ 初期の合言葉 **guinness** は辞書に載っている単語で推測されやすいため、
   このタイミングで別の合言葉に変更することを推奨。

`SUPABASE_SERVICE_ROLE_KEY` と `SUPABASE_URL` はSupabaseが各Edge Functionに
自動で渡してくれるため、自分で設定する必要はない。

## 設計メモ

### 同期バグ対策（tangocho supaLoad の教訓）

tangochoでは「クラウドが空に見えた瞬間にローカルが上書き」する同期バグが発生した。
本アプリは対策として **ローカルにデータを一切保存しない** 設計にしている：

```
tangocho:  ローカル保存 ⇄ クラウド ……… 上書き事故の余地あり 💥
ポータル:  操作 → 即クラウド書込 → Realtime通知 → 全端末が再取得 ✅
           （クラウドが唯一の正。ローカル→クラウドの上書き経路が存在しない）
```

### 車予約の重複防止（二段構え）

1. **UI側**: フォーム入力中に既存予約と照合し、重なっていたら予約ボタンを無効化
2. **DB側**: `tstzrange` の排他制約。他の端末とほぼ同時に予約しても後者はエラー（23P01）になり、画面に「時間が重なっています」と表示

### 買い物 ⇄ 在庫の循環

```
🥚在庫「切れた」タップ ──→ 🛒リストに「在庫切れ」バッジ付きで追加
                              │
🥚在庫に賞味期限付きで復帰 ←── 購入チェック →「在庫に反映しますか？」
```

### 将来の拡張

- **Kakeibo連携**: `subscriptions` テーブルは name / amount / cycle / note を持つため、
  Kakeibo側から月次支出として読むだけで連携可能（列追加も自由）
- **PWA化**: manifest.json + Service Worker を足すだけの構成にしてある
