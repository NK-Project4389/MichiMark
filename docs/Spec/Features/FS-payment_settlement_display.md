# Feature Spec: FS-payment_settlement_display

- **Spec ID**: FS-payment_settlement_display
- **要件書**: REQ-payment_settlement_display
- **作成日**: 2026-04-13
- **担当**: architect
- **ステータス**: 確定
- **種別**: UI改善（UI-9）

---

# 1. Feature Overview

## Feature Name

PaymentSettlementDisplay（旅費集計「支払いごとの精算」誤認防止）

## Purpose

EventDetail 概要タブの旅費集計セクション内「支払いごとの精算」ブロックが `Card`（elevation付き）で実装されており、タップ可能な要素に見えて誤認が生じている。

表示専用（タップ不可）であることを視覚的に明示するため、`Card` を背景色ティント＋左ボーダーの `Container` に置き換える。

## Scope

含むもの
- `_PerPaymentSettlementCard` ウィジェットの見た目変更（`Card` → `Container`）
- ウィジェットクラスのリネーム（`_PerPaymentSettlementCard` → `_PerPaymentSettlementBlock`）

含まないもの
- ロジック・Projection・Adapter・Bloc の変更
- 表示内容（精算金額・支払者名）の変更
- タップ機能の追加
- 他のセクションのデザイン変更

---

# 2. 変更対象

## ファイル

```
flutter/lib/features/overview/view/travel_expense_overview_view.dart
```

## 変更クラス

| 変更前 | 変更後 |
|---|---|
| `_PerPaymentSettlementCard` | `_PerPaymentSettlementBlock` |

変更箇所は上記クラスの `build()` メソッド内のみ。外部インターフェース（コンストラクタ引数 `settlement`）は変更しない。

---

# 3. 実装方針

## Card → Container への置き換え

`_PerPaymentSettlementCard` の `build()` 内の `Card` ウィジェットを、以下の仕様の `Container` に置き換える。

| 項目 | 値 |
|---|---|
| 背景色 | `Color(0xFFEAF5FB)`（Tealティント） |
| 左ボーダー | 幅 3dp、色 `Color(0xFF2B7A9B)`（Teal） |
| elevation | 0（Cardを廃止してフラット化） |
| 内側パディング | 12dp（既存のCardと同じ） |
| 下マージン | 8dp（既存のPaddingと同じ） |

## Container の構造方針

- `Container` の `decoration` に `BoxDecoration` を使い、`color` と `border` を設定する
- `Border` は左辺のみ（`Border(left: BorderSide(...))`）を指定する
- 内側コンテンツ（`Column`）は変更しない
- `borderRadius` は設定しない（ティントブロックのフラットな見た目とする）

## クラス参照の更新

`TravelExpenseOverviewView.build()` 内の `_PerPaymentSettlementCard` 参照を `_PerPaymentSettlementBlock` に更新する。

---

# 4. Data Flow

本変更は純粋なUI変更のため、データフローに変更なし。

- Projection からのデータ受け取り方（コンストラクタ経由）は変更しない
- `PerPaymentSettlementProjection` の型・フィールドは変更しない
- `TravelExpenseOverviewAdapter` は変更しない

---

# 5. Test Scenarios

## 前提条件

- iOSシミュレーターが起動済みであること
- 旅費データ（支払い情報）が存在するイベントが少なくとも1件登録されていること
- 概要タブに「支払いごとの精算」ブロックが表示される状態であること

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-PSD-001 | 支払いごとの精算ブロックが表示される | High |
| TC-PSD-002 | 支払いごとの精算ブロックにCardの影がない | High |

---

## シナリオ詳細

### TC-PSD-001: 支払いごとの精算ブロックが表示される

**前提:**
- 旅費データ（支払い情報）が存在するイベントを起動時に読み込める状態であること

**操作手順:**
1. アプリを起動し、イベント一覧を表示する
2. 旅費データが存在するイベントをタップする
3. EventDetail 画面の「概要」タブをタップする
4. 画面をスクロールして「支払いごとの精算」セクションを表示する

**期待結果:**
- `Key('travelExpenseOverview_block_perPaymentSettlement_0')` のウィジェットが画面上に存在する
- ブロック内に支払者名・精算金額が表示される

**実装ノート（ウィジェットキー一覧）:**

| キー | 説明 |
|---|---|
| `Key('travelExpenseOverview_block_perPaymentSettlement_0')` | 「支払いごとの精算」ブロック（インデックス付き） |

---

### TC-PSD-002: 支払いごとの精算ブロックにCardの影がない

**前提:**
- TC-PSD-001 の状態が達成されていること（概要タブに精算ブロックが表示されている）

**操作手順:**
1. TC-PSD-001 の手順 1〜4 を実行する
2. 表示された「支払いごとの精算」ブロックのウィジェット型を確認する

**期待結果:**
- `Key('travelExpenseOverview_block_perPaymentSettlement_0')` を持つウィジェットが `Card` 型ではない
- `Key('travelExpenseOverview_block_perPaymentSettlement_0')` を持つウィジェットが `Container` 型である

**実装ノート（ウィジェットキー一覧）:**

| キー | 説明 |
|---|---|
| `Key('travelExpenseOverview_block_perPaymentSettlement_0')` | 「支払いごとの精算」ブロック（インデックス付き）。このキーは `Container` に付与される |

---

# End of Feature Spec
