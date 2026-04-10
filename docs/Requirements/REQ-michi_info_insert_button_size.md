# REQ-michi_info_insert_button_size: MichiInfoカード間挿入ボタンの大型化

## 要件番号
REQ-michi_info_insert_button_size

## 優先度
Low

## 背景・目的
MichiInfoのタイムラインでカード間に表示される挿入インジケーター（`_InsertIndicator`）のタップ領域が小さく、操作しにくい。ボタンを大きくして操作性を向上させる。

## 要件

### REQ-MIB-001: インジケーターのタップ領域拡大
- `_InsertIndicator` の高さを現行より大きくする（目安: 現行 32dp → 48dp 以上）
- アイコンサイズも合わせて拡大する（目安: Icons.add_circle_outline → 28dp 以上）

### REQ-MIB-002: 視認性向上
- Amber カラーを維持しつつ、インジケーターのコントラストを高める
- InsertMode 時のインジケーター全体が視認しやすいこと

## 備考
- `_InsertIndicator` は `michi_info_view.dart` 内で定義
- InsertMode が false の場合は表示されない（既存動作を維持）
