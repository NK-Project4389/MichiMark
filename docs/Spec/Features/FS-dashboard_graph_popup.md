# Feature Spec: FS-dashboard_graph_popup

- **Spec ID**: FS-dashboard_graph_popup
- **要件書**: REQ-dashboard_graph_popup
- **作成日**: 2026-04-16
- **担当**: architect
- **ステータス**: 確定
- **種別**: UI改善（UI-22）
- **関連Spec**: FS-dashboard

---

# 1. Feature Overview

## Feature Name

DashboardGraphPopup（移動コストグラフ ポップアップ改善）

## Purpose

ダッシュボードの移動コストグラフ（`MovingCostDashboardView`）のタップ・長押し操作時に表示されるポップアップ（ツールチップ）の視認性を改善する。
配色を白文字+暗色背景に変更し、長押し時に走行距離と金額の両方を表示することでグラフの操作性を向上させる。

## Scope

含むもの
- `MovingCostDashboardView` の `BarTouchTooltipData` 設定変更（配色・表示内容）
- タップ時: 日付 + 金額（円）の表示
- 長押し時: 日付 + 走行距離（km） + 金額（円）の表示
- ポップアップ配色定数の一元管理（Widget内ハードコーディング禁止）
- 長押し状態の管理（Widget層のローカルステートで完結）

含まないもの
- 作業記録（visitWork）グラフのポップアップ変更
- 旅費（travelExpense）カレンダービューへの変更
- Bloc / Adapter / Domain 層の変更
- グラフのデータ取得ロジックの変更
- アニメーション付きポップアップ表示
- 複数棒の同時選択

---

# 2. Feature Responsibility

本改善はWidget層のみで完結する。

- `MovingCostDashboardView`（`moving_cost_dashboard_view.dart`）の `BarChart` 設定を変更する
- 長押し状態は `StatefulWidget` のローカル変数（`bool isLongPressing` + `int? longPressedIndex`）で管理する
- Bloc・Adapter・Domain 層は変更しない

---

# 3. State Structure

本Specは既存の `DashboardState` / `MovingCostDashboardProjection` を変更しない。

長押し状態はWidget層のローカルステートで管理する。

| フィールド | 型 | 説明 |
|---|---|---|
| `isLongPressing` | `bool` | 長押し中かどうか |
| `longPressedBarIndex` | `int?` | 長押し中のバーインデックス（0〜6）。nullは非長押し |

---

# 4. Draft Model

本Specはドラフトを持たない（表示専用Widget改善のため）。

---

# 5. Domain Model

本Specはドメインモデルを変更しない。
`DailyMovingCostEntry`（`distanceKm`・`costYen`・`dateLabel`）を参照するのみ。

---

# 6. Projection Model

本Specはプロジェクションを変更しない。
既存の `MovingCostDashboardProjection` / `DailyMovingCostEntry` をそのまま参照する。

---

# 7. Adapter

本Specはアダプターを変更しない。

---

# 8. Events

本Specは新規BlocEventを追加しない。長押し状態はWidget層のローカルステートで完結する。

---

# 9. Delegate

本Specは新規Delegateを追加しない。

---

# 10. ポップアップ仕様

## 10-1. 配色定数

ポップアップの配色は定数ファイル（または既存テーマファイル）で一元定義する。Widget内でのハードコーディングは禁止。

| 定数名 | 値の方針 |
|---|---|
| `graphTooltipBackgroundColor` | `Colors.black87` 相当の暗色半透明 |
| `graphTooltipTextColor` | `Colors.white` |
| `graphTooltipBorderRadius` | `BorderRadius.circular(8)` 相当 |

## 10-2. タップ時ポップアップ（既存動作を改善）

- 表示内容: **日付ラベル**（例: 「4/9」）+ **金額**（例: 「¥1,200」）
- `costYen` が null の場合は金額行を「---」と表示する
- `BarTouchTooltipData` の `getTooltipItem` で実装する

## 10-3. 長押し時ポップアップ（新規）

- 長押し検知: fl_chart の `BarTouchData.onLongPressMoveUpdate` または `longPressDuration` を使用する
- 表示内容: **日付ラベル** + **走行距離**（例: 「52.3 km」）+ **金額**（例: 「¥1,200」）
- 長押し中はポップアップを継続表示する
- 指を離したとき（`onLongPressEnd` または `onBarLongPressEnd` 相当）にポップアップを非表示にする（`longPressedBarIndex = null`）

## 10-4. movingCost / movingCostEstimated の両対応

- `MovingCostDashboardProjection` の `hasFuelData` が false の場合、タップ・長押し時ともに金額行は「---」と表示する
- グラフデータの取得ロジックは変更しない

---

# 11. Widget Key

| キー | 要素 | 用途 |
|---|---|---|
| `Key('movingCost_tooltip_tap')` | タップ時ポップアップ全体 | Integration Test でポップアップ表示確認 |
| `Key('movingCost_tooltip_longpress')` | 長押し時ポップアップ全体 | Integration Test でポップアップ表示確認 |

既存キー（変更なし）:

```
Key('moving_cost_dashboard_chart')
Key('moving_cost_total_distance_label')
Key('moving_cost_total_cost_label')
Key('moving_cost_avg_fuel_label')
```

---

# 12. Data Flow

```
ユーザーがグラフの棒をタップ / 長押し
  ↓
fl_chart の BarTouchData コールバック
  ↓
Widget ローカルステート更新（isLongPressing / longPressedBarIndex）
  ↓
setState → BarChart 再ビルド
  ↓
BarTouchTooltipData.getTooltipItem が DailyMovingCostEntry を参照
  ↓
ポップアップ表示（暗色背景・白文字）
```

Bloc / Adapter / Domain 層は一切関与しない。

---

# 13. ファイル変更範囲

変更対象:
- `flutter/lib/features/dashboard/view/moving_cost_dashboard_view.dart` — `BarChart` の `BarTouchData` / `BarTouchTooltipData` 設定変更・`StatefulWidget` 化

新規追加（定数定義の場所として候補）:
- `flutter/lib/core/theme/graph_tooltip_constants.dart`（既存テーマファイルがある場合はそこに追記）

変更しないファイル:
- `dashboard_bloc.dart` / `dashboard_event.dart` / `dashboard_state.dart`
- `moving_cost_dashboard_projection.dart`
- `moving_cost_dashboard_adapter.dart`
- その他全Featureのファイル

---

# 14. Test Scenarios

## 前提条件

- シードデータに `movingCost` トピックのイベントが存在すること（走行距離・給油コストあり）
- iOSシミュレーター起動済み
- ダッシュボードタブが表示されていること

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-GP-001 | 移動コストグラフの棒をタップしたとき、暗色背景・白文字のポップアップが表示される | High |
| TC-GP-002 | タップ時のポップアップに日付と金額が表示される | High |
| TC-GP-003 | 移動コストグラフの棒を長押ししたとき、走行距離と金額の両方が表示される | High |
| TC-GP-004 | 長押しを離したときポップアップが非表示になる | High |
| TC-GP-005 | costYen が null（給油なし日）のバーのポップアップに「---」が表示される | Medium |

## シナリオ詳細

### TC-GP-001: 移動コストグラフの棒をタップしたとき、暗色背景・白文字のポップアップが表示される

**前提:**
- movingCost チップが選択済み
- `Key('moving_cost_dashboard_chart')` が表示されている

**操作手順:**
1. `Key('moving_cost_dashboard_chart')` 内の任意の棒グラフをタップする

**期待結果:**
- `Key('movingCost_tooltip_tap')` が表示される
- ポップアップが画面上に表示されている（視認可能）

**実装ノート:**
- fl_chart の `BarTouchData.onTouchCallback` でタップイベントを検知する
- ポップアップは `BarTouchTooltipData.getTooltipItem` で生成する

---

### TC-GP-002: タップ時のポップアップに日付と金額が表示される

**前提:**
- TC-GP-001 の状態（ポップアップ表示中）

**操作手順:**
1. `Key('moving_cost_dashboard_chart')` 内の任意の棒グラフをタップする

**期待結果:**
- `Key('movingCost_tooltip_tap')` 内に日付文字列（「M/d」形式）が含まれる
- `Key('movingCost_tooltip_tap')` 内に金額文字列（「¥X,XXX」または「---」）が含まれる
- 走行距離は表示されない

---

### TC-GP-003: 移動コストグラフの棒を長押ししたとき、走行距離と金額の両方が表示される

**前提:**
- movingCost チップが選択済み
- `Key('moving_cost_dashboard_chart')` が表示されている

**操作手順:**
1. `Key('moving_cost_dashboard_chart')` 内の任意の棒グラフを長押しする（500ms 以上）

**期待結果:**
- `Key('movingCost_tooltip_longpress')` が表示される
- ポップアップ内に日付文字列が含まれる
- ポップアップ内に走行距離文字列（「XX.X km」形式）が含まれる
- ポップアップ内に金額文字列（「¥X,XXX」または「---」）が含まれる

---

### TC-GP-004: 長押しを離したときポップアップが非表示になる

**前提:**
- TC-GP-003 の状態（長押しポップアップ表示中）

**操作手順:**
1. 長押しを解除する（指を離す）

**期待結果:**
- `Key('movingCost_tooltip_longpress')` が非表示になる

---

### TC-GP-005: costYen が null（給油なし日）のバーのポップアップに「---」が表示される

**前提:**
- movingCost チップが選択済み
- シードデータに給油なし日のエントリが存在すること

**操作手順:**
1. 給油なし日（costYen が null）の棒グラフをタップする

**期待結果:**
- `Key('movingCost_tooltip_tap')` が表示される
- ポップアップ内に「---」が含まれる（金額が未記録であることを示す）
