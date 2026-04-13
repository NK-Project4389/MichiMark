# Feature Spec: 給油集計「満タン給油で算出」文言追加

**Spec ID**: FS-fuel_aggregation_fulltank_label
**要件書**: `docs/Requirements/REQ-fuel_aggregation_fulltank_label.md`
**作成日**: 2026-04-13
**ステータス**: Confirmed

---

## 1. Feature Overview

### Feature Name

FuelAggregationFulltankLabel

### Purpose

概要タブ（EventDetail）の給油集計セクションに「満タン給油で算出」というサブテキストを追加し、燃費の算出前提をユーザーに明示する。

### Scope

含むもの
- `MovingCostOverviewView` の給油集計表示エリアへのサブテキスト追加
- `MovingCostOverviewProjection` への `hasFuelData: bool` フィールド追加
- `EventDetailOverviewAdapter` での `hasFuelData` 算出追加

含まないもの
- 燃費の計算ロジックの変更
- 給油集計セクション以外の変更
- 新規BlocEvent・Draftの追加
- OverviewBlocロジックの変更

---

## 2. 変更対象ファイル

| ファイルパス | Widget / Class名 | 変更種別 |
|---|---|---|
| `flutter/lib/features/overview/view/moving_cost_overview_view.dart` | `MovingCostOverviewView` | 変更（サブテキスト追加） |
| `flutter/lib/features/overview/projection/moving_cost_overview_projection.dart` | `MovingCostOverviewProjection` | 変更（`hasFuelData` フィールド追加） |
| `flutter/lib/adapter/event_detail_overview_adapter.dart` | `EventDetailOverviewAdapter` | 変更（`hasFuelData` 算出追加） |

---

## 3. Projection フィールド変更

### MovingCostOverviewProjection への追加フィールド

| フィールド名 | 型 | 説明 |
|---|---|---|
| `hasFuelData` | `bool` | 給油データが1件以上存在する場合 `true`。`AggregationResult.totalGasQuantity` が非nullの場合に `true` とする |

**設計方針:**
- Widget側が `totalGasQuantityLabel != '---'` という文字列判定をすることは禁止する（UIロジックをWidgetに持たせない）
- `hasFuelData` の算出責務はAdapter層（`EventDetailOverviewAdapter`）が担う
- `hasFuelData` は `AggregationResult.totalGasQuantity != null` に対応する

---

## 4. 表示仕様

### 表示条件

`MovingCostOverviewProjection.hasFuelData == true` の場合のみ表示する。

### 表示位置

「費用」セクション内、「給油量」行の直下または「ガソリン代」行の直下にサブテキストとして配置する。

具体的には `_InfoRow(label: 'ガソリン代', ...)` の直後に配置する。

### 表示文言

```
満タン給油で算出
```

### テキストスタイル

| 属性 | 値 |
|---|---|
| フォントサイズ | `Theme.of(context).textTheme.bodySmall` に準拠（約12sp） |
| 色 | `Theme.of(context).colorScheme.onSurfaceVariant`（グレー系） |
| 配置 | 左寄せ、`_InfoRow` の value 側（右カラム）に合わせる |

---

## 5. Data Flow

- 変更なし。既存の `OverviewStarted` → `OverviewBloc` → `AggregationService` → `EventDetailOverviewAdapter` → `MovingCostOverviewProjection` のフローを継続する
- `EventDetailOverviewAdapter` が `AggregationResult.totalGasQuantity` の null チェックを行い `hasFuelData` を算出してProjectionに含める
- `MovingCostOverviewView` は `hasFuelData` の値を参照し、`true` の場合のみサブテキストを描画する

---

## 6. テストシナリオ

### 前提条件

- iOSシミュレーターが起動済みであること
- テスト用の給油データ（isFuel=true の MarkLink）が1件以上登録済みのイベントが存在すること（TC-FFL-001用）
- 給油データが0件のイベントが存在すること（TC-FFL-002用）

### テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-FFL-001 | 給油データありのイベント概要タブに「満タン給油で算出」が表示される | High |
| TC-FFL-002 | 給油データなしのイベント概要タブに「満タン給油で算出」が表示されない | High |

### シナリオ詳細

#### TC-FFL-001: 給油データありのイベント概要タブに「満タン給油で算出」が表示される

**前提:**
- 給油データ（isFuel=true の MarkLink）が1件以上登録済みのイベントが存在する

**操作手順:**
1. イベント一覧から上記イベントをタップする
2. EventDetail 画面が開く（概要タブが先頭）
3. 概要タブの集計セクション（給油集計エリア）が表示されるまでスクロールする

**期待結果:**
- 集計セクションに「満タン給油で算出」のテキストが表示される

**実装ノート（ウィジェットキー一覧）:**

| ウィジェットキー | 対象要素 |
|---|---|
| `Key('movingCostOverview_text_fulltankLabel')` | 「満タン給油で算出」テキストWidget |

---

#### TC-FFL-002: 給油データなしのイベント概要タブに「満タン給油で算出」が表示されない

**前提:**
- 給油データが0件（isFuel=true の MarkLink が存在しない）のイベントが存在する

**操作手順:**
1. イベント一覧から上記イベントをタップする
2. EventDetail 画面が開く（概要タブが先頭）
3. 概要タブの集計セクションが表示されるまでスクロールする

**期待結果:**
- 集計セクションに「満タン給油で算出」のテキストが表示されない
- `Key('movingCostOverview_text_fulltankLabel')` を持つWidgetが存在しない

**実装ノート（ウィジェットキー一覧）:**

| ウィジェットキー | 対象要素 |
|---|---|
| `Key('movingCostOverview_text_fulltankLabel')` | 「満タン給油で算出」テキストWidget（非表示を確認する対象） |

---

## End of Spec
