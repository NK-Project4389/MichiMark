# Feature Spec: FS-dashboard

- **Spec ID**: FS-dashboard
- **要件書**: REQ-dashboard
- **作成日**: 2026-04-15
- **担当**: architect
- **ステータス**: 確定
- **種別**: 機能追加（F-2）

---

# 1. Feature Overview

## Feature Name

Dashboard（ダッシュボード）

## Purpose

イベントと並列の新タブ「ダッシュボード」を追加し、トピック別・期間別のサマリーをグラフ・KPIで可視化する。無料版は期間固定（移動コスト・作業記録: 直近7日間、旅費: 全期間）。有料版の期間指定拡張に備えた設計にする。

## Scope

含むもの
- ボトムナビゲーションに「ダッシュボード」タブ追加
- DashboardBloc / DashboardState / DashboardEvent
- トピック選択チップ（単一選択）
- 移動コスト ダッシュボードビュー（コンボグラフ + KPI）
- 旅費 ダッシュボードビュー（カレンダー + KPI + よく使うルートTop3 仮実装・非表示）
- 作業記録 ダッシュボードビュー（コンボグラフ + ドーナツグラフ + KPI）
- 各トピック用 Projection / Adapter

含まないもの
- 有料版の期間指定・月次切り替えUI
- グラフのインタラクティブ操作（タップでドリルダウンなど）
- 旅費の「よく使うルートTop3」の表示（仮実装のみ・Widget非表示）
- 移動コスト率（visitWork × movingCost の横断集計）
- 既存 EventDetail・MichiInfo 画面の変更

---

# 2. Feature Responsibility

- Repositoryから期間・トピックに応じたデータを読み込む
- Adapter経由でグラフデータ・KPI Projectionを生成する
- Widget（View）への表示のみ担当

Draft保有なし（表示専用 Feature）。RootはこのFeatureの内部状態を変更しない。

---

# 3. ファイル構成

```
flutter/lib/features/dashboard/
  bloc/
    dashboard_bloc.dart
    dashboard_event.dart
    dashboard_state.dart
  projection/
    dashboard_projection.dart          # TopicChip・共通
    moving_cost_dashboard_projection.dart
    travel_expense_dashboard_projection.dart
    visit_work_dashboard_projection.dart
  adapter/
    moving_cost_dashboard_adapter.dart
    travel_expense_dashboard_adapter.dart
    visit_work_dashboard_adapter.dart
  view/
    dashboard_page.dart                # タブ全体・チップ
    moving_cost_dashboard_view.dart
    travel_expense_dashboard_view.dart
    visit_work_dashboard_view.dart
```

---

# 4. State Structure

```dart
class DashboardState extends Equatable {
  final List<TopicType> availableTopics;  // データが存在するトピック一覧
  final TopicType? selectedTopic;         // 選択中トピック（nullは未初期化）
  final DateRange period;                 // 表示期間（有料版拡張に備え保持）
  final MovingCostDashboardProjection? movingCostProjection;
  final TravelExpenseDashboardProjection? travelExpenseProjection;
  final VisitWorkDashboardProjection? visitWorkProjection;
  final bool isLoading;

  const DashboardState({...});

  DashboardState copyWith({...}) => ...;

  @override
  List<Object?> get props => [
    availableTopics, selectedTopic, period,
    movingCostProjection, travelExpenseProjection,
    visitWorkProjection, isLoading,
  ];
}
```

### DateRange（期間パラメータ）

```dart
class DateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  /// 無料版: 当日起算の直近7日間を生成
  factory DateRange.last7Days() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59);
    return DateRange(start: start, end: end);
  }

  @override
  List<Object?> get props => [start, end];
}
```

旅費は `DateRange` を使わず全イベントを対象とする（Adapter側で制御）。

---

# 5. Events

```dart
abstract class DashboardEvent extends Equatable {}

/// 画面初期化（タブ表示時）
class DashboardInitialized extends DashboardEvent {
  @override List<Object?> get props => [];
}

/// トピックチップ選択
class DashboardTopicSelected extends DashboardEvent {
  final TopicType topic;
  const DashboardTopicSelected(this.topic);
  @override List<Object?> get props => [topic];
}
```

---

# 6. Bloc Responsibility

```
DashboardInitialized
  → EventRepository.loadAll() でイベント一覧取得
  → データが存在するTopicTypeを抽出 → availableTopics
  → 最初の availableTopic を selectedTopic に設定
  → 選択トピックの Adapter を呼び出し Projection 生成
  → isLoading: false で emit

DashboardTopicSelected
  → selectedTopic 更新
  → 対応 Adapter を呼び出し Projection 生成（他トピックは再計算しない）
  → emit
```

禁止事項
- Navigation操作（タブ遷移はRootが管理）
- Repository の直接変更（読み取りのみ）

---

# 7. Projection Models

## 7-1. MovingCostDashboardProjection

```dart
class MovingCostDashboardProjection extends Equatable {
  final List<DailyMovingCostEntry> dailyEntries;  // 日別データ（7件）
  final String totalDistanceLabel;   // 「XXX km」
  final String totalCostLabel;       // 「¥X,XXX」または「---」
  final String avgFuelEfficiencyLabel; // 「XX.X km/L」または「---」（movingCostのみ）
  final bool hasFuelData;            // 給油実績があるか（燃費表示の要否）

  @override List<Object?> get props => [...];
}

class DailyMovingCostEntry extends Equatable {
  final DateTime date;
  final double distanceKm;
  final int? costYen;          // その日の給油コスト（nullは未給油）
  final int cumulativeCostYen; // 累積コスト（折れ線用）
  final String dateLabel;      // 「4/9」形式

  @override List<Object?> get props => [...];
}
```

## 7-2. TravelExpenseDashboardProjection

```dart
class TravelExpenseDashboardProjection extends Equatable {
  final DateTime displayMonth;          // 表示中の月（初期値: 当月）
  final List<TravelEventCalendarEntry> calendarEntries; // バッジ表示用
  final String tripCountLabel;          // 「X 件」
  final String spotCountLabel;          // 「X か所」
  final String totalExpenseLabel;       // 「¥X,XXX」
  final List<TopRouteEntry> topRoutes;  // よく使うルートTop3（仮実装・非表示）

  @override List<Object?> get props => [...];
}

class TravelEventCalendarEntry extends Equatable {
  final DateTime date;
  final String eventId;     // タップ時の遷移先イベントID
  final String eventTitle;  // バッジ内テキスト（EventName 先頭8文字）
  final Color topicColor;   // トピックカラー

  @override List<Object?> get props => [...];
}

class TopRouteEntry extends Equatable {
  final String routeName;    // 「地点A → 地点B」形式
  final int usageCount;      // 走行回数
  final double totalDistanceKm;

  @override List<Object?> get props => [...];
}
```

## 7-3. VisitWorkDashboardProjection

```dart
class VisitWorkDashboardProjection extends Equatable {
  final List<DailyVisitWorkEntry> dailyEntries; // 日別データ（7件）
  final List<WorkBreakdownEntry> workBreakdown; // ドーナツグラフ用内訳
  final String totalWorkTimeLabel;    // 「XX時間XX分」
  final String totalRevenueLabel;     // 「¥X,XXX」または「---」
  final String hourlyRateLabel;       // 「¥X,XXX / h」または「---」
  final String utilizationRateLabel;  // 「XX%」（作業日数/7日）
  final String totalDistanceLabel;    // 「XXX km」
  final Map<String, String> workTimeBreakdownLabels; // アクション名 → 時間ラベル

  @override List<Object?> get props => [...];
}

class DailyVisitWorkEntry extends Equatable {
  final DateTime date;
  final Map<String, double> workHoursByAction; // アクション別作業時間（積み上げ用）
  final int revenueYen;   // 当日売上（折れ線用）
  final String dateLabel; // 「4/9」形式

  @override List<Object?> get props => [...];
}

class WorkBreakdownEntry extends Equatable {
  final String actionName;
  final double hours;
  final double percentage;
  final Color color;

  @override List<Object?> get props => [...];
}
```

---

# 8. Adapter

## 8-1. MovingCostDashboardAdapter

```dart
class MovingCostDashboardAdapter {
  static MovingCostDashboardProjection toProjection(
    List<EventDomain> events,
    DateRange period,
  );
}
```

- `period` 内の events を対象とする（EventDomain.date で絞り込み）
- 対象トピック: `movingCost` / `movingCostEstimated`
- 7日分の DailyMovingCostEntry を生成（データなし日は distanceKm: 0.0 / costYen: null）
- cumulativeCostYen: 開始日からの累積合計

## 8-2. TravelExpenseDashboardAdapter

```dart
class TravelExpenseDashboardAdapter {
  static TravelExpenseDashboardProjection toProjection(
    List<EventDomain> events,
    DateTime displayMonth,
  );
}
```

- 全イベントを対象（期間フィルタなし）
- `displayMonth` の月内イベントのみ calendarEntries に含める
- KPI（旅行回数・スポット数・総支出）は displayMonth 内のみ集計
- topRoutes: Link一覧から走行回数上位3件を算出（データ不足時は空リスト）
  - **Widgetでは非表示**（`showTopRoutes: false` で制御）

## 8-3. VisitWorkDashboardAdapter

```dart
class VisitWorkDashboardAdapter {
  static VisitWorkDashboardProjection toProjection(
    List<EventDomain> events,
    DateRange period,
  );
}
```

- `period` 内の events を対象（TopicType.visitWork のみ）
- ActionTimeDomain を使って作業時間内訳を算出
- 時間単価: `totalRevenueYen / totalWorkHours`（どちらか0なら「---」）
- 稼働率: `作業が存在した日数 / 7 * 100`

---

# 9. View

## 9-1. DashboardPage

- ボトムナビゲーション: イベント一覧タブの右隣に「ダッシュボード」タブ追加
  - キー: `Key('dashboard_tab')`
- 上部にトピック選択チップを横スクロールで表示
  - 各チップキー: `Key('topic_chip_${topicType.name}')`
  - 選択中チップはトピックカラーで強調
- 選択トピックに応じて以下のViewを切り替え表示:
  - `MovingCostDashboardView`
  - `TravelExpenseDashboardView`
  - `VisitWorkDashboardView`
- データ0件・未初期化時: 「データがありません」プレースホルダー
  - キー: `Key('dashboard_empty_placeholder')`

## 9-2. MovingCostDashboardView

グラフ: `fl_chart` の `BarChart` + `LineChart` 重ね表示
- 左Y軸: 走行距離（km）→ BarChart
- 右Y軸: 累積コスト（円）→ LineChart
- X軸: 7日分の日付ラベル
- KPIカード: 総走行距離 / 総コスト / 平均燃費（hasFuelData=false時は非表示）

キー一覧:
```
Key('moving_cost_dashboard_chart')
Key('moving_cost_total_distance_label')
Key('moving_cost_total_cost_label')
Key('moving_cost_avg_fuel_label')
```

## 9-3. TravelExpenseDashboardView

- カレンダー: `table_calendar` パッケージを使用
  - イベント存在日にバッジ（`calendarEntries` を `eventLoader` に渡す）
  - バッジタップ: `DashboardTravelEventTapped` イベント発火 → Delegate でイベント画面遷移
  - 月ナビゲーション（前月・翌月ボタン）タップ: `DashboardMonthChanged` イベント発火
- KPIカード: 旅行回数 / 訪問スポット数 / 総支出（今月）
- TopRoutes: **表示しない**（Projectionには含まれるがWidgetに `if (false)` ブロックを設ける）

キー一覧:
```
Key('travel_expense_calendar')
Key('travel_expense_trip_count_label')
Key('travel_expense_spot_count_label')
Key('travel_expense_total_expense_label')
```

## 9-4. VisitWorkDashboardView

グラフ1: コンボグラフ（作業時間積み上げ縦棒 + 売上折れ線）
グラフ2: ドーナツグラフ（`fl_chart` の `PieChart`）
- KPIカード: 総作業時間 / 総売上 / 時間単価 / 稼働率 / 総走行距離

キー一覧:
```
Key('visit_work_dashboard_combo_chart')
Key('visit_work_dashboard_donut_chart')
Key('visit_work_total_work_time_label')
Key('visit_work_total_revenue_label')
Key('visit_work_hourly_rate_label')
Key('visit_work_utilization_rate_label')
Key('visit_work_total_distance_label')
```

---

# 10. Navigation

旅費カレンダーのバッジタップ時:

```dart
class DashboardTravelEventTapped extends DashboardDelegate {
  final String eventId;
  const DashboardTravelEventTapped(this.eventId);
  @override List<Object?> get props => [eventId];
}
```

Root（AppRouter）が `DashboardTravelEventTapped` を受け取り `EventDetail` へ遷移する。

---

# 11. グラフライブラリ

| ライブラリ | 用途 |
|---|---|
| `fl_chart` | コンボグラフ・ドーナツグラフ |
| `table_calendar` | 旅費カレンダー |

`pubspec.yaml` への追加は実装時に行う。

---

# 12. 将来拡張ポイント

- `DateRange` を Bloc のイベントで変更可能にしておくことで、有料版の月次・期間指定UIを追加しやすくする
- `TravelExpenseDashboardState` に `displayMonth` を持たせることで月ナビゲーションも拡張可能
- TopRoutes は Projection / Adapter に実装済みのため、有料版UIのみ追加すれば表示可能

---

# 13. Test Scenarios

## 前提条件

- シードデータに movingCost / travelExpense / visitWork それぞれのイベントが存在すること
- iOSシミュレーター起動済み

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-DB-001 | ダッシュボードタブが表示される | High |
| TC-DB-002 | movingCostチップを選択すると移動コストビューが表示される | High |
| TC-DB-003 | 移動コストKPIラベルが表示される | High |
| TC-DB-004 | travelExpenseチップを選択するとカレンダーが表示される | High |
| TC-DB-005 | カレンダーのイベントバッジをタップするとEventDetailへ遷移する | High |
| TC-DB-006 | visitWorkチップを選択すると作業記録ビューが表示される | High |
| TC-DB-007 | 作業記録KPIラベルが表示される | High |
| TC-DB-008 | データが0件の場合にプレースホルダーが表示される | Medium |

## シナリオ詳細

### TC-DB-001: ダッシュボードタブが表示される

**操作手順:**
1. アプリを起動する
2. ボトムナビゲーションの `Key('dashboard_tab')` をタップする

**期待結果:**
- ダッシュボード画面が表示される
- トピック選択チップが1件以上表示される
- 最初のトピックが自動選択される

---

### TC-DB-002: movingCostチップを選択すると移動コストビューが表示される

**操作手順:**
1. ダッシュボードタブを表示する
2. `Key('topic_chip_movingCost')` をタップする

**期待結果:**
- `Key('moving_cost_dashboard_chart')` が表示される
- `Key('moving_cost_total_distance_label')` が表示される

---

### TC-DB-003: 移動コストKPIラベルが表示される

**操作手順:**
1. movingCostチップを選択する

**期待結果:**
- `Key('moving_cost_total_distance_label')` のテキストが「--- km」または距離を示す文字列
- `Key('moving_cost_total_cost_label')` が表示される

---

### TC-DB-004: travelExpenseチップを選択するとカレンダーが表示される

**操作手順:**
1. ダッシュボードタブを表示する
2. `Key('topic_chip_travelExpense')` をタップする

**期待結果:**
- `Key('travel_expense_calendar')` が表示される
- KPIラベル3種が表示される

---

### TC-DB-005: カレンダーのイベントバッジをタップするとEventDetailへ遷移する

**操作手順:**
1. travelExpenseチップを選択する
2. カレンダー上のイベントバッジをタップする

**期待結果:**
- EventDetail画面へ遷移する

---

### TC-DB-006: visitWorkチップを選択すると作業記録ビューが表示される

**操作手順:**
1. ダッシュボードタブを表示する
2. `Key('topic_chip_visitWork')` をタップする

**期待結果:**
- `Key('visit_work_dashboard_combo_chart')` が表示される
- `Key('visit_work_dashboard_donut_chart')` が表示される

---

### TC-DB-007: 作業記録KPIラベルが表示される

**操作手順:**
1. visitWorkチップを選択する

**期待結果:**
- `Key('visit_work_total_work_time_label')` が表示される
- `Key('visit_work_total_revenue_label')` が表示される
- `Key('visit_work_hourly_rate_label')` が表示される
- `Key('visit_work_utilization_rate_label')` が表示される

---

### TC-DB-008: データが0件の場合にプレースホルダーが表示される

**操作手順:**
1. データが存在しないトピックチップを選択する（またはデータ0件の状態で初期化する）

**期待結果:**
- `Key('dashboard_empty_placeholder')` が表示される
- グラフ・KPIは表示されない
