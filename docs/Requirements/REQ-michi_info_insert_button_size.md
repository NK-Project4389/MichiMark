# REQ-michi_info_insert_button_size: MichiInfoカード間挿入ボタンの改善

## 要件番号
REQ-michi_info_insert_button_size

## 優先度
Medium

## 背景・目的
MichiInfoのタイムラインでカード間に表示される挿入インジケーター（`_InsertIndicator`）について、
以下の改善を行い、操作性・視認性を向上させる。

## 現状
- `_InsertIndicator`: height 24dp、icon size 16dp（`Icons.add_circle_outline`、Amber）
- 先頭カードの上にはインジケーターが表示されない（最初のカードの前は空白）
- 構造: index 0 = `SizedBox.shrink()`（非表示）

## 要件

### REQ-MIB-001: インジケーターのサイズ拡大（カードに少し被るサイズ感）
- `_InsertIndicator` の高さを拡大し、上下のカードに少し被るくらいのサイズにする
- 負のmargin（`Padding` の代わりに `Transform.translate` または `margin: EdgeInsets.symmetric(vertical: -N)` 等）を使い、カードと重なる表現を実現する
- アイコンサイズも合わせて拡大する（目安: 28dp 以上）

### REQ-MIB-002: 先頭カードの上にも「＋」を表示
- InsertMode 時、先頭カード（index 0 のアイテム）の上にも `_InsertIndicator` を表示する
- 挿入時のseq指定は先頭挿入専用の値（例: insertAfterSeq = -1 または 0）を使用する
- 既存の「0件時の追加ボタン」動作（insertAfterSeq = -1）との競合に注意すること

### REQ-MIB-003: 「＋」アイコンのデザイン改善（designer担当）
- 視覚的に視認しやすいデザインに変更する
- 変更対象は「＋」アイコン部分のみ（罫線・Divider・カラースキームはそのまま）
- Amberカラー系は維持しつつ、アイコン自体の形状・スタイルを改善する
- **designerがデザイン提案を行い、product-managerがレビューしてユーザー確認後に実装する**

## 実装対象ファイル
- `lib/features/michi_info/view/michi_info_view.dart`
  - `_InsertIndicator` ウィジェット（行1500-1536）
  - SliverList の構築ロジック（行667-705）

## 備考
- InsertMode が false の場合は表示されない（既存動作を維持）
- REQ-MIB-001・002 は実装・レビュー・テストのサイクルで対応
- REQ-MIB-003 はデザインフローを経て別途Specに反映
