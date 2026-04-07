# 要件書: MarkLink カード C-2 デザイン

作成日: 2026-04-07
作成者: product-manager
バージョン: 1.0
参照デザイン叩き: `docs/Design/draft/2026-04-07_marklink_card_design_draft.md`

---

## 概要

MichiInfo タイムライン画面の Mark（地点）カードと Link（区間）カードのビジュアルを刷新する。
現行の Material colorScheme ベースの単色カードから、**C-2（タイムライン連結型・中央フローティングバッジ）スタイル** に改良する。

---

## ユーザーストーリー

- ユーザーとして、地点（Mark）カードを一目で区間（Link）カードと見分けたい
  → Mark: 白背景 + Teal上ボーダー + 円形ドット、Link: コンパクト + Emerald枠で明確に差別化
- ユーザーとして、区間の距離情報がカード外に表示されることで「道のりのデータ」として直感的に理解したい
- ユーザーとして、タイムライン縦線が Mark ゾーン（Teal）・Link ゾーン（Emerald）で色分けされることで、ドライブルートの流れをビジュアルに把握したい

---

## 機能要件

### REQ-MKC-01: Mark カード外観

- 背景色: ホワイト (`#FFFFFF`)
- 上ボーダー: 3dp solid Teal Primary (`#2B7A9B`)
- 角丸: 16dp
- 影: `boxShadow: 0 2px 8px rgba(0,0,0,0.09)`
- 高さ目安: 72dp（`_cardHeight` 定数に合わせる）
- タイトル: 13px / W700 / `#1A1A2E`
- メーター値（サブテキスト）: 11px / W600 / Teal Primary (`#2B7A9B`)

### REQ-MKC-02: Mark ドット

- 形状: 円形 20dp
- 塗り: Teal Primary (`#2B7A9B`)
- 白枠: 3dp（カード背景色と同一）
- ドロップシャドウ: `0 0 0 2px #2B7A9B`（glow効果）

### REQ-MKC-03: Link カード外観（コンパクト化）

- 背景色: Emerald Tint Light (`#EDFAF4`)
- 境界線: 1.5px solid `#C3EBD8`
- 角丸: 8dp
- 高さ: **34dp**（Mark カード 72dp の約半分・コンパクト化）
- タイトル: 11px / W600 / `#1A1A2E`

### REQ-MKC-04: Link ドット

- 形状: 角丸矩形 14dp × 14dp（角丸 4dp）
- 塗り: Emerald Primary (`#2E9E6B`)
- 影: `0 2px 4px rgba(46,158,107,0.3)`

### REQ-MKC-05: 水平コネクタ線（ドット → カード左端）

- Mark: Teal Primary (`#2B7A9B`)、長さ 18dp
- Link: Emerald Primary (`#2E9E6B`)、不透明度 55%、長さ 14dp

### REQ-MKC-06: タイムライン縦線 カラー分け

- Mark ゾーン（Mark 間・隣接 Link がない区間）: 2px / Teal Primary 40% 透明度 (`#2B7A9B` alpha 0.4)
- Link ゾーン（Link カードの行）: 6px / Emerald グラデーション (`#2E9E6B` → `#1A7A52`)・角丸 3dp
- 縦線はカード高さ範囲のみ描画（行間パディング部分は縦線なし）

### REQ-MKC-07: 距離表示（カード外）

- Link 行の右外に距離数値を独立配置（現行 `_LinkDistanceCell` を引き続き利用・スタイルのみ更新）
- 数値: 13px / W800 / Emerald Primary (`#2E9E6B`)
- 単位: 8px / W600 / Emerald Dark (`#1A7A52`)
- 距離が null の場合: 数値エリアを空欄表示（スペースは確保）

### REQ-MKC-08: スパン矢印（Mark 間合計距離）

- 現行 `_MichiTimelineCanvas` のスパン矢印を維持
- 矢印色: Teal Primary (`#2B7A9B`)

---

## 非機能要件

- Flutter Material colorScheme を基本としつつ、C-2 スタイルに必要な定義済みカラーを定数として追加する
  - カラー定数は `michi_info_view.dart` 内 private const として定義する（他 Feature への影響なし）
- 既存の MichiInfoBloc / Event / State / Projection / Repository の構造は変更しない（Widget 層のみ変更）
- `dart analyze` エラー・警告 0 を維持する
- `_cardHeight` 定数（72.0）を維持する（スパン矢印座標計算に影響するため変更不可）
- Link カード高さ変更に合わせてスパン矢印の Y 座標計算を更新する（`_actionButtonsHeight` の扱いに注意）

---

## スコープ外

- ダークテーマ対応
- FAB型挿入UI（別タスク T-064〜T-067）
- アニメーション
- 距離単位の切り替え

---

## 受け入れ条件

- [ ] Mark カードが白背景 + Teal 上ボーダー + 円形ドット（glow）で表示される
- [ ] Link カードが 34dp コンパクト高さ + Emerald 枠で表示される
- [ ] タイムライン縦線が Mark ゾーン: Teal 細線 / Link ゾーン: Emerald 太線（グラデーション）で表示される
- [ ] 距離ラベルがカード外（右側）に Emerald 色で表示される
- [ ] 既存の Mark / Link タップ操作（詳細画面遷移）が引き続き動作する
- [ ] `_MarkActionButtons` が Mark カード下に引き続き表示される
- [ ] `dart analyze` エラー・警告 0

---
