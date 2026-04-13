# 要件書: 旅費集計「支払いごとの精算」誤認防止デザイン変更

- **要件ID**: REQ-payment_settlement_display
- **作成日**: 2026-04-13
- **担当**: product-manager
- **ステータス**: 確定
- **種別**: UI改善（UI-9）
- **デザイン参照**: docs/Design/draft/payment_settlement_display_design.html（B案採用）

---

## 1. 背景・目的

EventDetail 概要タブの旅費集計セクション内「支払いごとの精算」ブロックが `Card` ウィジェット（elevation付き）で実装されており、タップできるように見えてしまい誤認が発生している。

表示専用（タップ不可）であることを視覚的に明示するデザインに変更する。

---

## 2. 採用デザイン: B案（背景ティント + 左ボーダー）

| 項目 | 内容 |
|---|---|
| 変更対象Widget | `_PerPaymentSettlementCard`（`Card` → `Container` に置き換え） |
| 背景色 | `#EAF5FB`（Tealティント、既存カラーシステムの `brand-teal-tint2`） |
| 左ボーダー | 幅 3dp、色 `#2B7A9B`（Teal） |
| elevation | **0**（Cardを廃止してフラット化） |
| クラスリネーム（任意） | `_PerPaymentSettlementCard` → `_PerPaymentSettlementBlock` |

---

## 3. 変更スコープ

| 対象 | 変更内容 |
|---|---|
| `travel_expense_overview_view.dart` の `_PerPaymentSettlementCard` | `Card` を `Container`（ティント背景＋左ボーダー）に置き換え |
| ロジック・Projection・Adapter | **変更なし** |
| 表示内容（精算金額・支払者名） | **変更なし** |

---

## 4. 対象外

- タップ機能の追加（表示専用のまま）
- 他のセクションのデザイン変更

---

## 5. テストシナリオ

| TC-ID | シナリオ | 期待結果 |
|---|---|---|
| TC-PSD-001 | 旅費データが存在するイベントの概要タブを開く | 「支払いごとの精算」ブロックが表示されている |
| TC-PSD-002 | 「支払いごとの精算」ブロックの見た目を確認する | Card（影付き）ではなくフラットな背景色ブロックとして表示される |
