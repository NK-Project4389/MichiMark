# デザイン要件の叩き: 入力画面UI刷新

## 概要

BasicInfo / MarkDetail / LinkDetail / PaymentDetail の4画面と MichiInfo FABボタンを対象に、
テキスト入力・マスター選択・タグセクション・ボタン・セパレーターのビジュアルを統一する。

ユーザー指摘5点（テキストボックス境界不明確・選択行のタップ誘導不足・タグ範囲不明確・ボタン統一感なし・セパレーターなし）を解消し、
iOS ネイティブアプリの設定画面に近いシンプルで明快な印象に刷新する。

---

## 変更項目

### A. テキスト入力フィールド（全4画面共通）

- [ ] `InputDecoration` を `OutlineInputBorder` に変更する
- [ ] 通常時のボーダー色: `#B2DFDB`（Teal Light）、幅 1.5
- [ ] フォーカス時のボーダー色: `#4ECDC4`（Teal）、幅 1.5 + グロー (opacity 0.15)
- [ ] フィールドラベルは入力枠の外上部に小キャプション形式で表示（11px / SemiBold / #3E5A5A）
- [ ] プレースホルダー色: `#9BB5B3`
- [ ] 数値入力フィールドは末尾に単位テキスト（km/L・円/L・km・円）を表示（suffix）

### B. マスター選択行（交通手段・メンバー・ガソリン支払者・支払者・割り勘メンバー等）

- [ ] 背景色を `#F0FAFA`（Teal Tint2）に設定する
- [ ] 枠線を `#3AADA5`（Teal Mid）、幅 1.5 で囲む（角丸 10px）
- [ ] 右端の矢印アイコンを `#2D6A6A` 塗りつぶし丸アイコン（直径 22px・白矢印）に変更する
- [ ] 行ラベルは上部小キャプション（11px / SemiBold / #3E5A5A）、選択値は 13px テキスト（#1A1A2E）の縦並び構成にする
- [ ] テキスト入力行と視覚的に明確に区別できること

### C. タグセクション（BasicInfo）

- [ ] タグセクション全体を3つのゾーンに分割する

  **ゾーン1: 登録済みタグ**
  - [ ] 白背景（`#FFFFFF`）
  - [ ] セクション見出し「登録済みタグ」（10px / Bold / `#2D6A6A` / uppercase）
  - [ ] チップスタイル: 背景 `#E0F7F5`、ボーダー `#4ECDC4`、テキスト `#2D6A6A`、角丸 20px
  - [ ] チップ末尾に × ボタンで削除可能なことを視覚的に示す

  **ゾーン2: レコメンドタグ**
  - [ ] 背景 `#F9FCFC`（Teal Tint2 より淡い）
  - [ ] セクション見出し「レコメンド」（10px / Bold / `#5C7070` / uppercase）
  - [ ] チップスタイル: 背景 `#F4F8F8`、ボーダー `#B2DFDB`、テキスト `#5C7070`、角丸 20px
  - [ ] チップ末尾に + ボタンで追加可能なことを示す

  **ゾーン3: 新規入力フィールド**
  - [ ] 通常のテキスト入力フィールド（A の仕様に準拠）
  - [ ] ラベル「タグを追加」、プレースホルダー「新しいタグを入力...」

- [ ] 各ゾーン間は `#E5F0EE` の Divider で分割する

### D. ボタン（全4画面共通）

- [ ] 保存ボタン: `ElevatedButton`
  - 背景色 `#2D6A6A`（Teal Dark）、テキスト白、角丸 12px、縦 padding 11px
  - テキスト 14px / Bold
- [ ] キャンセルボタン: `TextButton`
  - テキスト色 `#5C7070`（Secondary）、背景なし
  - テキスト 14px / Regular
- [ ] 画面下部のボタン行は「キャンセル（左・固定幅）/ 保存（右・flex 1）」の横並びで統一する
- [ ] ナビゲーションバーにも同等のテキストアクション（左: キャンセル / 右: 保存・Teal色）を配置する

### E. セパレーター（Divider）（全4画面共通）

- [ ] 各フォーム項目間に `#E5F0EE`（1px）の Divider を設ける
- [ ] セクション境界（例: 燃料情報セクション区切り）は `#B2DFDB`（1px）の強いDividerを使用する
- [ ] セクションヘッダーがある場合は `#F9FCFC` 背景 + 見出しテキスト（10px / Bold / `#2D6A6A`）形式で明示する

### F. MichiInfo FABボタン

- [ ] 通常時: 拡張FAB（角丸 16px・Teal Dark #2D6A6A 背景・白「+」アイコン + 「追加」テキスト）
- [ ] スクロール時: 円形FABに縮小（直径 52px・同色）してコンテンツ領域を確保する
- [ ] タップ時の状態: 背景色を `#245858`（Teal Dark -5%）に変化させてフィードバックを与える
- [ ] ドロップシャドウ: `rgba(45,106,106,0.35)` / blur 14px / offset Y 4px

---

## 対象画面

| 画面 | 変更カテゴリ |
|---|---|
| BasicInfo（基本情報編集） | A / B / C / D / E |
| MarkDetail（地点詳細） | A / B / D / E |
| LinkDetail（区間詳細） | A / B / D / E |
| PaymentDetail（支払詳細） | A / B / D / E |
| MichiInfo（タイムライン画面） | F のみ |

## 修正対象外

- MichiInfo のタイムライン一覧部分（Mark/Link カード）は修正対象外

---

## カラートークン参照

| トークン名 | 値 | 用途 |
|---|---|---|
| Input Border | `#B2DFDB` | テキスト入力枠（通常時） |
| Focus Ring | `#4ECDC4` | テキスト入力枠（フォーカス時） |
| Select BG | `#F0FAFA` | 選択行背景 |
| Select Border | `#3AADA5` | 選択行枠線 |
| Select Arrow | `#2D6A6A` | 選択行矢印アイコン背景 |
| Divider | `#E5F0EE` | 項目間セパレーター |
| Divider Strong | `#B2DFDB` | セクション間セパレーター |
| Tag Chip BG | `#E0F7F5` | 登録済みタグチップ背景 |
| Tag Chip Border | `#4ECDC4` | 登録済みタグチップ枠 |
| Tag Chip Text | `#2D6A6A` | 登録済みタグチップ文字 |
| Tag Rec BG | `#F4F8F8` | レコメンドタグチップ背景 |
| Tag Rec Border | `#B2DFDB` | レコメンドタグチップ枠 |
| Tag Rec Text | `#5C7070` | レコメンドタグチップ文字 |
| Btn Primary BG | `#2D6A6A` | 保存ボタン背景 |
| Btn Primary Hover | `#245858` | 保存ボタンタップ時 |
| Btn Cancel Text | `#5C7070` | キャンセルボタンテキスト |
| Text Label | `#3E5A5A` | フィールドラベル |
| Text Placeholder | `#9BB5B3` | プレースホルダー |

---

## 参照デザインレポート

`docs/Design/draft/2026-04-08_input_screen_redesign.html`

---

## 備考

- 本書は designer が作成した叩き。product-manager によるレビュー・ユーザー承認後に `docs/Requirements/` へ正式格納すること
- 承認前に architect / flutter-dev への作業依頼は行わないこと
