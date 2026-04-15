# Feature Spec: F-3 訪問作業トピック（visitWork）

Platform: **Flutter / Dart**
Version: 1.0
Status: Draft
Created: 2026-04-15
Requirement: `docs/Requirements/REQ-visit_work_topic.md`

---

# 1. Feature Overview

## Feature Name

VisitWorkTopic

## Purpose

個人事業主の訪問作業記録に特化したトピック種別 `visitWork` を追加する。
既存の `ActionTimeLog` / `AggregationResult` / `PaymentInfo` を流用し、
訪問作業専用アクション・状態遷移インタープリター・プログレスバー集計を新規追加する。

## Scope

### 追加するもの

| 分類 | 対象 |
|---|---|
| Domain | `TopicType.visitWork` 追加 |
| Domain | `VisitWorkTimeline` / `VisitWorkSegment` / `VisitWorkAggregation` 新規クラス |
| Domain service | `VisitWorkStateInterpreter` 新規クラス |
| TopicConfig | `TopicType.visitWork` の case 追加 |
| Seed data | 訪問作業専用 ActionDomain 5件 + TopicDomain 1件 |
| MichiInfo 集計タブ | visitWork 向けプログレスバー + 時間サマリー + 売上サマリー表示 |

### 既存機能の流用（変更なし）

| 機能 | 流用方法 |
|---|---|
| `ActionState` | `waiting` = 滞在状態として流用（ラベルは Projection で上書き） |
| `AggregationResult` | `movingTime` / `workingTime` / `breakTime` / `waitingTime` / `totalPayment` をそのまま使用 |
| `ActionTimeLog` | スキーマ変更なし・そのまま使用 |
| `ActionDomain.isToggle` | 休憩トグルに使用 |
| `MarkLinkDomain` | Markのみ使用・Link不要 |
| `PaymentInfo` | 売上として使用 |

---

# 2. Domain 変更

## 2.1 TopicType への追加

**ファイル:** `flutter/lib/domain/topic/topic_domain.dart`

```dart
enum TopicType {
  movingCost,
  movingCostEstimated,
  travelExpense,
  visitWork,  // ← 追加
}
```

## 2.2 TopicConfig への追加

**ファイル:** `flutter/lib/domain/topic/topic_config.dart`

switch の case に追加する。

```dart
TopicType.visitWork => const TopicConfig(
  showMeterValue: true,        // 走行メーター記録あり
  showFuelDetail: false,
  addMenuItems: [AddMenuItemType.mark],  // Mark のみ（Link 追加ボタンなし）
  showLinkDistance: false,
  showKmPerGas: false,
  showPricePerGas: false,
  showPayMember: false,        // メンバー選択なし
  showPaymentInfoTab: true,    // 売上を PaymentInfo で管理
  markActions: [               // Markタップ時に提示するアクション（シードIDと対応）
    'visit_work_arrive',
    'visit_work_depart',
    'visit_work_start',
    'visit_work_end',
    'visit_work_break',
  ],
  linkActions: [],
  showActionTimeButton: true,  // ⚡ ボタン表示
  themeColor: TopicThemeColor.skyBlue,  // 訪問作業テーマカラー
  displayName: '訪問作業',
  showNameField: true,         // 訪問先名を表示
  showMarkDate: true,
  showMarkMembers: false,
  showLinkDate: false,
),
```

> **テーマカラー:** `skyBlue` が未定義の場合は新規追加する。
> `TopicThemeColor` に `skyBlue` を追加し、対応する Flutter Color を定義する。
> 既存パレットに適切な色がある場合はそちらを使用してよい。

---

# 3. 新規 Domain オブジェクト

**ファイル:** `flutter/lib/domain/visit_work/`

## 3.1 VisitWorkSegment

ActionTimeLog の解釈結果として得られる1つの状態区間。

```dart
// flutter/lib/domain/visit_work/visit_work_segment.dart
import 'package:equatable/equatable.dart';
import '../action_time/action_state.dart';

class VisitWorkSegment extends Equatable {
  final ActionState state;
  final DateTime from;
  final DateTime to;

  const VisitWorkSegment({
    required this.state,
    required this.from,
    required this.to,
  });

  Duration get duration => to.difference(from);

  @override
  List<Object?> get props => [state, from, to];
}
```

## 3.2 VisitWorkTimeline

インタープリターの出力。複数の VisitWorkSegment の時系列リスト。

```dart
// flutter/lib/domain/visit_work/visit_work_timeline.dart
import 'package:equatable/equatable.dart';
import 'visit_work_segment.dart';

class VisitWorkTimeline extends Equatable {
  /// 時系列順のセグメントリスト
  final List<VisitWorkSegment> segments;

  /// 最後のアクションが「出発」以外 = 進行中
  final bool isOngoing;

  const VisitWorkTimeline({
    required this.segments,
    required this.isOngoing,
  });

  /// タイムライン全体の開始時刻（最初のセグメントの from）
  DateTime? get startTime => segments.isEmpty ? null : segments.first.from;

  /// タイムライン全体の終了時刻（isOngoing == true なら null）
  DateTime? get endTime => isOngoing ? null : segments.last.to;

  /// 現地滞在開始（最初の「到着」セグメントの from）
  /// moving → waiting に遷移した最初のタイミング
  DateTime? get arrivedAt {
    for (final seg in segments) {
      if (seg.state == ActionState.waiting) return seg.from;
    }
    return null;
  }

  /// 現地滞在終了（最後の「出発」前の区切り）
  /// waiting → moving に遷移した最後のタイミング
  DateTime? get departedAt {
    if (isOngoing) return null;
    for (final seg in segments.reversed) {
      if (seg.state == ActionState.moving) return seg.from;
    }
    return null;
  }

  /// 在現地時間（到着〜出発の合計時間）
  Duration? get onSiteDuration {
    final a = arrivedAt;
    final d = departedAt;
    if (a == null) return null;
    final end = d ?? DateTime.now();
    return end.difference(a);
  }

  @override
  List<Object?> get props => [segments, isOngoing];
}
```

## 3.3 VisitWorkAggregation

表示向けの集計値オブジェクト。Adapterで算出する。

```dart
// flutter/lib/domain/visit_work/visit_work_aggregation.dart
import 'package:equatable/equatable.dart';

class VisitWorkAggregation extends Equatable {
  final Duration movingDuration;
  final Duration stayingDuration;   // ActionState.waiting の合計
  final Duration workingDuration;
  final Duration breakDuration;
  final Duration? onSiteDuration;   // 到着〜出発の合計（出発前は null）
  final int? revenue;               // 売上合計（円）。Payment 未登録は null
  final bool isOngoing;

  const VisitWorkAggregation({
    required this.movingDuration,
    required this.stayingDuration,
    required this.workingDuration,
    required this.breakDuration,
    this.onSiteDuration,
    this.revenue,
    required this.isOngoing,
  });

  /// 時給換算（売上 ÷ 作業時間）。作業時間0 or 売上null の場合は null
  int? get revenuePerHour {
    if (revenue == null) return null;
    final hours = workingDuration.inMinutes / 60.0;
    if (hours == 0) return null;
    return (revenue! / hours).round();
  }

  @override
  List<Object?> get props => [
    movingDuration, stayingDuration, workingDuration, breakDuration,
    onSiteDuration, revenue, isOngoing,
  ];
}
```

---

# 4. VisitWorkStateInterpreter

**ファイル:** `flutter/lib/domain/visit_work/visit_work_state_interpreter.dart`

ActionTimeLog のリストを VisitWorkTimeline に変換する純粋な Domain Service。
外部依存なし・DB 操作なし。

## 4.1 アルゴリズム

```
入力: List<ActionTimeLog> logs（時系列昇順）, Map<String, ActionDomain> actionMap

1. logs を timestamp 昇順にソートする
2. currentState = null（初期状態）
3. preBreakState = null（休憩前の状態を記憶する変数）
4. segments = []

各 log を順に処理:
  action = actionMap[log.actionId]

  if action == null → スキップ（削除済みActionDomainへの参照）

  if action.isToggle（休憩トグル）:
    if currentState == ActionState.break_:
      // 休憩 OFF: 直前の状態に戻る
      nextState = preBreakState ?? ActionState.waiting
      preBreakState = null
    else:
      // 休憩 ON: 現在状態を記憶してbreak へ
      preBreakState = currentState ?? ActionState.waiting
      nextState = ActionState.break_
  else:
    nextState = action.toState（nullの場合はcurrentStateのまま）

  if currentState != null && prevTimestamp != null:
    segments.add(VisitWorkSegment(
      state: currentState,
      from: prevTimestamp,
      to: log.timestamp,
    ))

  currentState = nextState
  prevTimestamp = log.timestamp

5. 最後のセグメント（進行中区間）を追加:
   if currentState != null:
     isOngoing = (currentState != ActionState.moving || segments.isEmpty)
     // ※ 最後が moving かつ出発済みなら完了、それ以外は進行中
     segments.add(VisitWorkSegment(
       state: currentState,
       from: prevTimestamp,
       to: isOngoing ? DateTime.now() : prevTimestamp（ダミー・使わない）
     ))

return VisitWorkTimeline(segments: segments, isOngoing: isOngoing)
```

> **NOTE:** "進行中" の判定ロジックは要件確認後に詰める。
> シンプルな実装として「最後に記録されたアクションが出発（toState == moving）なら完了」でよい。

## 4.2 「休憩ON中に別のアクションを記録した場合」の BLoC 側処理

インタープリターはログを純粋に解釈するだけ。
休憩中のアクション記録は **BLoC 側** で処理する：

```
MichiInfoBloc がアクションボタンタップを受け取ったとき:
  if currentState == ActionState.break_ && action.isToggle == false:
    1. 「休憩OFF」ActionTimeLog を挿入する（visit_work_break アクションで timestamp = now）
    2. 新しいアクションの ActionTimeLog を挿入する
    3. UI の isBreakActive = false に更新する
```

---

# 5. シードデータ

## 5.1 ActionDomain シード（5件）

`flutter/lib/data/seed/seed_actions.dart` に追加する。

| seedId（固定UUID） | actionName | toState | isToggle | togglePairId | needsTransition |
|---|---|---|---|---|---|
| `visit_work_arrive` | 到着 | `ActionState.waiting` | false | null | true |
| `visit_work_depart` | 出発 | `ActionState.moving` | false | null | true |
| `visit_work_start` | 作業開始 | `ActionState.working` | false | null | true |
| `visit_work_end` | 作業終了 | `ActionState.waiting` | false | null | true |
| `visit_work_break` | 休憩 | null | true | null | true |

> **seedId の UUID:** 実装時に `uuid` パッケージで固定値を生成してハードコードする。
> シードデータは DB 初期化時に挿入するため、UUID は変更不可とする。

## 5.2 TopicDomain シード（1件）

| seedId | topicName | topicType | isVisible |
|---|---|---|---|
| `topic_visit_work` | 訪問作業 | `visitWork` | true |

---

# 6. Adapter

**ファイル:** `flutter/lib/features/event_detail/adapter/visit_work_aggregation_adapter.dart`

EventDetail（または MichiInfo）の Adapter に追加する。

```dart
/// AggregationResult + VisitWorkTimeline → VisitWorkAggregation に変換する
class VisitWorkAggregationAdapter {
  static VisitWorkAggregation fromResults({
    required AggregationResult aggregation,
    required VisitWorkTimeline timeline,
  }) {
    return VisitWorkAggregation(
      movingDuration: aggregation.movingTime ?? Duration.zero,
      stayingDuration: aggregation.waitingTime ?? Duration.zero,
      workingDuration: aggregation.workingTime ?? Duration.zero,
      breakDuration: aggregation.breakTime ?? Duration.zero,
      onSiteDuration: timeline.onSiteDuration,
      revenue: aggregation.totalPayment,
      isOngoing: timeline.isOngoing,
    );
  }
}
```

---

# 7. MichiInfo 集計タブ UI（visitWork 向け）

既存の集計タブ表示を TopicType で分岐し、visitWork の場合に以下を表示する。

## 7.1 プログレスバー（時間軸タイムライン）

Widget: `VisitWorkProgressBar`（新規）

```
[09:00]─────────────────────────────[13:00]
  ██移動██ ████████作業████████ ██休憩██ ████作業████
```

- 横幅 = 全体時間（startTime 〜 endTime or 現在時刻）
- 各セグメントの幅 = duration / 全体時間 の比率
- 色分け:
  - `moving` → グレー (`Colors.grey.shade400`)
  - `waiting` → ブルー (`Colors.blue.shade300`)
  - `working` → テーマカラー（Teal）
  - `break_` → オレンジ (`Colors.orange.shade300`)
- 左端に開始時刻・右端に終了時刻（または「進行中」）を表示
- Key: `Key('visit_work_progress_bar')`

## 7.2 時間サマリーセクション

```
┌─ 時間の内訳 ──────────────────┐
│ 移動    ██░░░░  1h 00m        │
│ 滞在    █░░░░░  30m           │
│ 作業    ████░░  3h 00m        │
│ 休憩    █░░░░░  30m           │
│─────────────────────────────│
│ 在現地  3h 30m（到着〜出発）   │
└────────────────────────────-─┘
```

- ラベルは Projection で `ActionState → 表示名` に変換する
  - `waiting` → 「滞在」（visitWork コンテキストでの上書き）
  - `moving` → 「移動」
  - `working` → 「作業」
  - `break_` → 「休憩」
- 時間未取得（ActionTimeLog なし）の場合は「---」表示

## 7.3 売上サマリーセクション

```
┌─ 売上 ─────────────────────────┐
│ 売上合計     ¥15,000           │
│ 時給換算     ¥5,000 / h       │  ← 作業時間 0 の場合は非表示
└────────────────────────────────┘
```

- `revenue == null`（PaymentInfo 未登録）の場合は「---」
- `revenuePerHour == null`（作業時間 0）の場合は行ごと非表示

---

# 8. Projection

`VisitWorkProjection`（または EventDetailOverview の visitWork ブランチ）

```dart
class VisitWorkProjection extends Equatable {
  final VisitWorkTimeline timeline;
  final VisitWorkAggregation aggregation;

  // 表示用ラベル
  String get movingLabel => '${_formatDuration(aggregation.movingDuration)}';
  String get stayingLabel => '${_formatDuration(aggregation.stayingDuration)}';
  String get workingLabel => '${_formatDuration(aggregation.workingDuration)}';
  String get breakLabel => '${_formatDuration(aggregation.breakDuration)}';
  String get onSiteLabel => aggregation.onSiteDuration != null
      ? _formatDuration(aggregation.onSiteDuration!)
      : '---';
  String get revenueLabel => aggregation.revenue != null
      ? '¥${NumberFormat('#,###').format(aggregation.revenue)}'
      : '---';
  String? get revenuePerHourLabel => aggregation.revenuePerHour != null
      ? '¥${NumberFormat('#,###').format(aggregation.revenuePerHour)} / h'
      : null;
}
```

---

# 9. ファイル構成（新規追加分）

```
flutter/lib/
  domain/
    topic/
      topic_domain.dart           ← TopicType.visitWork 追加
      topic_config.dart           ← visitWork case 追加
    visit_work/                   ← 新規ディレクトリ
      visit_work_segment.dart
      visit_work_timeline.dart
      visit_work_aggregation.dart
      visit_work_state_interpreter.dart
  features/
    event_detail/
      adapter/
        visit_work_aggregation_adapter.dart  ← 新規
      projection/
        visit_work_projection.dart           ← 新規
  data/
    seed/
      seed_actions.dart           ← visitWork 5件追加
      seed_topics.dart            ← visitWork トピック追加
  shared/
    widgets/
      visit_work_progress_bar.dart ← 新規
```

---

# 10. テストシナリオ

## 10.1 テストファイル

`flutter/integration_test/visit_work_topic_test.dart`

## 10.2 Unit Test（VisitWorkStateInterpreter）

`flutter/test/domain/visit_work/visit_work_state_interpreter_test.dart`

### Unit テストシナリオ

| ID | シナリオ | 検証内容 |
|---|---|---|
| TC-VW-U001 | 到着→作業開始→作業終了→出発の正常フロー | セグメント数・各状態・時間が正しく算出される |
| TC-VW-U002 | 休憩ONのみ（休憩OFFなし・進行中） | break_ セグメントが1件・isOngoing == true |
| TC-VW-U003 | 休憩ON→休憩OFF で直前状態（working）に戻る | break_ 後に working に戻るセグメントが生成される |
| TC-VW-U004 | ActionTimeLog が空 | segments == [] / isOngoing == false |
| TC-VW-U005 | onSiteDuration の算出（到着あり・出発あり） | 到着〜出発の Duration が正しい |
| TC-VW-U006 | revenuePerHour の算出 | 売上15000 / 作業3h = 5000 |

## 10.3 Integration Test シナリオ

| ID | シナリオ | ステップ | 優先度 |
|---|---|---|---|
| TC-VW-I001 | visitWork トピックでイベントを作成し、Mark を追加できる | イベント作成（visitWork 選択）→ MichiInfo → Mark 追加 | 高 |
| TC-VW-I002 | Mark タップでアクションボタン（到着/出発/作業開始/作業終了/休憩）が表示される | Mark タップ → ボトムシート確認 | 高 |
| TC-VW-I003 | 「到着」アクション記録 → 「滞在」状態バッジが表示される | アクション記録 → 状態バッジ確認 | 高 |
| TC-VW-I004 | 「作業開始」→「休憩」→「作業終了」の順で記録 → 集計タブにプログレスバーが表示される | アクション記録 × 3 → 集計タブ → バー表示確認 | 高 |
| TC-VW-I005 | 集計タブに時間サマリー（移動/滞在/作業/休憩）が表示される | 集計タブ確認 | 高 |
| TC-VW-I006 | 集計タブに売上合計・時給換算が表示される（PaymentInfo 登録後） | PaymentInfo に売上追加 → 集計タブ確認 | 中 |
| TC-VW-I007 | visitWork トピックでは Link 追加ボタンが非表示 | MichiInfo FAB 確認 | 中 |
| TC-VW-I008 | visitWork トピックでは Mark にメンバー選択が非表示 | MarkDetail 確認 | 中 |

---

# 11. 依存関係・制約

- **TopicThemeColor.skyBlue:** 未定義の場合は新規追加。既存パレット（10色）から近似色を選んでもよい
- **AggregationResult:** スキーマ変更なし・そのまま使用
- **ActionTimeLog:** スキーマ変更なし・`prevStatus` は interpreter で動的に解決
- **ActionState.waiting:** visitWork コンテキストでは「滞在」として扱う。ラベルは Projection で上書き
- **Phase B（MarkからPaymentDetail登録）:** POST-1/F-5 完了後に追加実装予定。本Specでは対象外
