# EventDetailOverview Feature Specification

Platform: **Flutter / Dart**
Version: 1.0
Purpose: EventDetailのOverviewタブの表示制御を担当し、TopicConfigに応じてmovingCost用集計表示とtravelExpense用収支バランス表示を切り替える。

> **注記**: 本Specは Topic_Spec.md §12 および Aggregation_Spec.md §9 に分散していたOverview設計を統合・確定版として定義したものである。実装はこの Spec を唯一の参照元とする。

---

# 1. Feature Overview

## Feature Name

EventDetailOverview

## Purpose

EventDetailのOverviewタブを担当する。TopicConfigの内容を参照して表示モードを切り替え、movingCost時はAggregationServiceを用いた時間・距離・費用の集計値を表示し、travelExpense時はTravelExpenseOverviewAdapterを用いた収支バランスを表示する。

## Scope

含むもの
- EventDetailOverviewBloc の設計（Event / State）
- OverviewDraft の定義
- MovingCostOverviewProjection の定義（Aggregation_Spec §9 から移管）
- TravelExpenseOverviewProjection の参照（Topic_Spec §12 で定義済み）
- EventDetailOverviewAdapter の責務定義
- TopicConfigによる表示切り替えロジックの設計（Adapter層に集約）
- Widgetの構成方針

含まないもの
- AggregationServiceの集計ロジック実装（Aggregation_Spec §7 が担当）
- TravelExpenseOverviewAdapterの収支バランス算出ロジック（Topic_Spec §12 が担当）
- AggregationPageの期間・フィルタ別集計（Aggregation_Spec §10 が担当）
- Overviewからの画面遷移（Phase 1ではなし）

---

# 2. Feature Responsibility

## このFeatureの責務

- OverviewDraft の所有
- EventDomainとTopicConfigを受け取りProjectionを生成する
- TopicConfigを参照してmovingCost用またはtravelExpense用のAdapterを呼び分ける
- 集計中・エラーの状態管理

## このFeatureが行わないこと

- 集計ロジックの実装（AggregationServiceに委譲）
- 収支バランスの算出ロジック（TravelExpenseOverviewAdapterに委譲）
- EventDomainの編集・保存
- Navigation操作（Phase 1ではDelegateなし）

## 依存Feature・責務境界

| 依存先 | 提供されるもの | 依存関係の方向 |
|---|---|---|
| Aggregation_Spec | AggregationService（時間・距離・費用の集計）、AggregationResult | EventDetailOverview → Aggregation |
| Topic_Spec | TopicConfig、TravelExpenseOverviewAdapter、TravelExpenseOverviewProjection | EventDetailOverview → Topic |
| ActionTime_Spec | ActionTimeLog、ActionState（AggregationServiceが内部的に参照） | 間接依存（直接参照しない） |

---

# 3. Domain Model

このFeatureが扱うDomainは以下の通り。いずれも参照のみで、編集・保存は行わない。

| Domain | 参照内容 |
|---|---|
| `EventDomain` | eventId・actionTimeLogs・markLinks（Links）・payments・topic |
| `TopicConfig` | topicType判定用（Topic_Spec §3 で定義済み） |
| `AggregationResult` | movingCost表示用の集計値（Aggregation_Spec §4 で定義済み） |
| `TravelExpenseOverviewProjection` | travelExpense表示用の収支バランス（Topic_Spec §12 で定義済み） |

---

# 4. Draft Model

OverviewはEvent編集を行わない。Draftはイベント参照用の最小構成とする。

## OverviewDraft フィールド定義

| フィールド名 | 型 | 説明 |
|---|---|---|
| `eventId` | `String` | 対象イベントのID |

- `Equatable` を継承する
- `const` コンストラクタを使用する
- 永続化しない

---

# 5. Projection Model

TopicConfigに応じて2種類のProjectionを使い分ける。BlocはどちらのProjectionを使うかをStateに乗せ、WidgetはStateを見て適切な表示を行う。

## 5.1 MovingCostOverviewProjection（movingCost用）

AggregationResult（時間・距離・費用のDomain値）を表示文字列に変換した読み取り専用値オブジェクト。

| フィールド名 | 型 | 説明 |
|---|---|---|
| `movingTimeLabel` | `String` | 移動時間の表示文字列。算出不可の場合は "---" |
| `workingTimeLabel` | `String` | 作業時間の表示文字列。算出不可の場合は "---" |
| `breakTimeLabel` | `String` | 休憩時間の表示文字列。算出不可の場合は "---" |
| `waitingTimeLabel` | `String` | 滞留時間の表示文字列。算出不可の場合は "---" |
| `totalDistanceLabel` | `String` | 総走行距離の表示文字列（例: "120km"） |
| `totalGasQuantityLabel` | `String` | 給油量の表示文字列（例: "30.0L"、なしは "---"） |
| `totalGasPriceLabel` | `String` | ガソリン代の表示文字列（例: "5,000円"、なしは "---"） |
| `totalPaymentLabel` | `String` | 経費合計の表示文字列（例: "3,000円"、なしは "---"） |

設計方針:
- `Equatable` を継承する
- `const` コンストラクタを使用する
- `AggregationResult` の null フィールドは "---" に変換する（変換責務はEventDetailOverviewAdapterが担う）

## 5.2 TravelExpenseOverviewProjection（travelExpense用）

Topic_Spec §12 で定義済み。本Specでは参照のみ。フィールド定義は Topic_Spec.md を参照。

---

# 6. Adapter

## EventDetailOverviewAdapter（新規）

担当: TopicConfigを参照し、適切なAdapterを呼び出してProjectionを生成して返す。集計ロジックを直接持たない。

### 責務

| 入力 | 処理 | 出力 |
|---|---|---|
| `AggregationResult` | null値 → "---" 変換・各値のフォーマット | `MovingCostOverviewProjection` |

### 設計方針

- `AggregationResult` → `MovingCostOverviewProjection` の変換のみ担当する
- `TravelExpenseOverviewAdapter`（Topic_Spec）は独立して存在するため、本Adapterは呼び出しのみ行う
- TopicConfigの切り替え判定はEventDetailOverviewBlocが行い、Adapterは変換のみに専念する
- 表示文字列フォーマットロジック（"120km"・"5,000円" 等）をここに集約する
- BLoC内に表示文字列フォーマットを記述しない

---

# 7. BLoC Events

## EventDetailOverviewEvent 一覧

| Event名 | 発火タイミング | ペイロード | 説明 |
|---|---|---|---|
| `OverviewStarted` | Overview画面の表示時 | `EventDomain event, TopicConfig topicConfig` | EventDomainとTopicConfigを受け取り集計を開始する |
| `OverviewTopicConfigUpdated` | EventDetailBlocからTopicが変更されたとき | `TopicConfig config, EventDomain event` | TopicConfigと最新EventDomainを受け取り集計を再実行する |

---

# 8. BLoC State

## EventDetailOverviewState フィールド定義

| フィールド名 | 型 | 説明 |
|---|---|---|
| `draft` | `OverviewDraft` | 対象イベントID |
| `topicConfig` | `TopicConfig` | 現在有効なTopicConfig（EventDetailBlocから伝播） |
| `movingCostProjection` | `MovingCostOverviewProjection?` | movingCost用Projection。集計完了後にnon-null |
| `travelExpenseProjection` | `TravelExpenseOverviewProjection?` | travelExpense用Projection。集計完了後にnon-null |
| `isLoading` | `bool` | 集計処理中フラグ |
| `errorMessage` | `String?` | エラーメッセージ |
| `delegate` | `OverviewDelegate?` | 遷移意図の通知（Phase 1はnull固定） |

設計方針:
- `Equatable` を継承する
- `movingCostProjection` / `travelExpenseProjection` は同時にnon-nullになることはない
- `isLoading = true` の間、Widgetはローディング表示を行う
- BlocはAdapterのみを呼び出す。集計ロジックをBloC内に記述しない

---

# 9. Delegate Contract

| Delegate名 | 通知先 | 説明 |
|---|---|---|
| （Phase 1ではなし） | - | Overviewは表示専用のため現フェーズでは遷移なし |

将来のPhaseでOverviewから詳細画面への遷移が追加される場合は、`OverviewDelegate` の sealed class を追加する。

---

# 10. BLoC Responsibility

EventDetailOverviewBlocが行うこと:
- `OverviewStarted` 受信時に `isLoading = true` でStateを更新し、TopicConfigに応じて適切なAdapterを呼び出す
- `topicConfig` が movingCost相当 → `AggregationService.aggregateEvent(event)` を呼び出してAggregationResultを得て、`EventDetailOverviewAdapter.toMovingCostProjection(result)` でProjectionを生成する
- `topicConfig` が travelExpense相当 → `TravelExpenseOverviewAdapter.toProjection(event)` を呼び出してProjectionを生成する
- 集計完了後に `isLoading = false` にしてProjectionをStateに乗せて emit する
- `OverviewTopicConfigUpdated` 受信時は topicConfig を更新し、集計を再実行する
- エラー発生時は `errorMessage` をStateに乗せて emit する

EventDetailOverviewBlocが行わないこと:
- 集計ロジックの実装（AggregationServiceに委譲）
- 収支バランスの算出（TravelExpenseOverviewAdapterに委譲）
- 表示文字列フォーマット（EventDetailOverviewAdapterに委譲）
- Navigation操作

依存するサービス・Adapter（DI注入）:
- `AggregationService`（get_it経由）
- `EventDetailOverviewAdapter`（get_it経由）
- `TravelExpenseOverviewAdapter`（get_it経由）

---

# 11. TopicConfigによる表示切り替えロジック

## 切り替えの判定基準

| 条件 | 使用するAdapter | 更新するProjectionフィールド |
|---|---|---|
| `topicConfig.showFuelDetail == true`（movingCost相当） | AggregationService + EventDetailOverviewAdapter | `movingCostProjection` |
| `topicConfig.showFuelDetail == false`（travelExpense相当） | TravelExpenseOverviewAdapter | `travelExpenseProjection` |

設計方針:
- BLocはTopicTypeを直接比較しない。TopicConfigのフラグを参照して判定する
- 切り替えの基準フラグは `showFuelDetail` を使用する（Topic_Spec §3 の設定値表を参照）
- Widget内でもTopicTypeをif/switch比較しない。StateのどちらのProjectionがnon-nullかで分岐する

---

# 12. Widget構成

## EventDetailOverviewPage

- `BlocBuilder<EventDetailOverviewBloc, EventDetailOverviewState>` でStateを受け取る
- `isLoading == true` のとき: ローディングインジケーターを表示する
- `errorMessage != null` のとき: エラーメッセージを表示する
- `movingCostProjection != null` のとき: `MovingCostOverviewView` を表示する
- `travelExpenseProjection != null` のとき: `TravelExpenseOverviewView` を表示する

## MovingCostOverviewView（movingCost用サブWidget）

- `MovingCostOverviewProjection` を受け取る（BlocBuilderではなくWidgetのコンストラクタ経由）
- 時間セクション: movingTimeLabel / workingTimeLabel / breakTimeLabel / waitingTimeLabel
- 距離セクション: totalDistanceLabel
- 費用セクション: totalGasQuantityLabel / totalGasPriceLabel / totalPaymentLabel

## TravelExpenseOverviewView（travelExpense用サブWidget）

- `TravelExpenseOverviewProjection` を受け取る（BlocBuilderではなくWidgetのコンストラクタ経由）
- 経費合計セクション: totalExpense の表示
- メンバーコストセクション: memberCosts の一覧
- 収支バランスセクション: memberBalances の一覧（プラス/マイナスで色分け等）

設計方針:
- サブWidgetはProjectionを直接受け取る。BlocをネストしてStateを直接読みに行かない
- サブWidgetはビジネスロジックを持たない

---

# 13. EventDetail Featureとの連携設計

EventDetailOverviewBlocはEventDetailBlocの子として扱われる。TopicConfigの変更通知はEventDetailBlocから受け取る。

## EventDetailBlocの拡張（既存Specへの補足）

Topic_Spec §11 で定義した伝播フローに以下を追加する。

| Event名 | 発火タイミング | ペイロード | 説明 |
|---|---|---|---|
| `OverviewTopicConfigUpdated` | EventDetailBlocがTopicConfigを再生成したとき | `TopicConfig config, EventDomain event` | OverviewBlocのTopicConfigと最新EventDomainを更新する |

## 伝播フロー（Topic_Spec §11 の拡張）

```
BasicInfoBloc（Topic変更）
  ↓ BasicInfoTopicChangedDelegate をStateに乗せる
EventDetailPageのBlocListener（Delegateを受け取る）
  ↓ EventDetailTopicChanged をEventDetailBlocへ送信する
EventDetailBloc（TopicConfig再生成）
  ↓ 各子BlocへEvent送信（一方向push）
    - MichiInfoBloc: MichiInfoTopicConfigUpdated
    - MarkDetailBloc: MarkDetailTopicConfigUpdated
    - LinkDetailBloc: LinkDetailTopicConfigUpdated
    - EventDetailOverviewBloc: OverviewTopicConfigUpdated（event付き）
EventDetailOverviewBloc（集計再実行）
```

---

# 14. Data Flow

## 初期表示フロー

1. EventDetailBlocがEventDetailOverviewBlocに `OverviewStarted` を送信する（EventDomainとTopicConfigを含む）
2. EventDetailOverviewBlocが `isLoading = true` でStateをemitする
3. EventDetailOverviewBlocがTopicConfigのフラグを確認する
4. movingCost相当の場合: `AggregationService.aggregateEvent(event)` を呼び出してAggregationResultを取得する
5. movingCost相当の場合: `EventDetailOverviewAdapter.toMovingCostProjection(result)` でMovingCostOverviewProjectionを生成する
6. travelExpense相当の場合: `TravelExpenseOverviewAdapter.toProjection(event)` でTravelExpenseOverviewProjectionを生成する
7. 生成したProjectionをStateに乗せて `isLoading = false` でemitする
8. WidgetがStateを受け取って表示する

## TopicConfig変更後の再集計フロー

1. Topic変更がEventDetailBlocに伝播する（Topic_Spec §11参照）
2. EventDetailBlocがEventDetailOverviewBlocに `OverviewTopicConfigUpdated` を送信する（更新後のTopicConfigと最新EventDomainを含む）
3. EventDetailOverviewBlocが `isLoading = true` でStateをemitする
4. 初期表示フローの3〜8を繰り返す

---

# 15. Navigation

Phase 1ではOverviewからの画面遷移なし。Delegateは未使用。

BlocListenerはDelegateが追加された場合の拡張に備えてEventDetailOverviewPageに設置する。

---

# 16. ファイル構成

```
flutter/lib/
  adapter/
    event_detail_overview_adapter.dart
      -- AggregationResult → MovingCostOverviewProjection の変換
  features/
    overview/
      bloc/
        overview_event.dart
          -- OverviewStarted, OverviewTopicConfigUpdated
        overview_state.dart
          -- EventDetailOverviewState
        overview_bloc.dart
          -- EventDetailOverviewBloc
      draft/
        overview_draft.dart
          -- OverviewDraft
      projection/
        moving_cost_overview_projection.dart
          -- MovingCostOverviewProjection
      view/
        event_detail_overview_page.dart
          -- EventDetailOverviewPage（BlocBuilder）
        moving_cost_overview_view.dart
          -- MovingCostOverviewView（サブWidget）
        travel_expense_overview_view.dart
          -- TravelExpenseOverviewView（サブWidget）
```

> `TravelExpenseOverviewProjection` は Topic_Spec に従い `flutter/lib/adapter/travel_expense_overview_adapter.dart` 付近に定義する。本Featureのprojectionディレクトリには置かない。

---

# 17. 受け入れ条件

- [ ] EventDetailのOverviewタブがmovingCost時に時間・距離・費用を表示する
- [ ] EventDetailのOverviewタブがtravelExpense時に経費合計・メンバー別コスト・収支バランスを表示する
- [ ] ActionTimeLogが0件または1件のEventのOverviewは時間項目が "---" と表示される
- [ ] Topic変更後にOverviewの表示内容が切り替わる
- [ ] 集計ロジックがBLoC内に記述されていない（AggregationService / TravelExpenseOverviewAdapterに委譲されている）
- [ ] 表示文字列フォーマットがEventDetailOverviewAdapter内に実装されており、BLoC・Widgetに書かれていない
- [ ] Widget内でTopicTypeをif/switch比較していない（StateのどちらのProjectionがnon-nullかで分岐している）
- [ ] TopicConfigフラグの参照のみで表示切り替えを判定している（TopicTypeを直接比較しない）
- [ ] EventDetailOverviewBlocはAggregationServiceとAdapterをDI（get_it）経由で受け取っている

---

# 18. 非機能方針

- Phase 3のカスタムTopic対応を見越してTopicTypeの直接比較を禁止する
- 集計はイベント表示時に都度算出する（キャッシュなし）。パフォーマンス問題が発生した場合に最適化を検討する
- 将来的にOverviewへのグラフ追加・詳細ドリルダウンが発生した場合は本Specを更新してから実装する

---

# 19. SwiftUI版との対応

| Flutter設計 | 対応SwiftUI要素 |
|---|---|
| EventDetailOverviewBloc | SwiftUI版のOverviewReducerに相当 |
| MovingCostOverviewProjection | SwiftUI版OverviewのmovingCost表示値に相当 |
| TravelExpenseOverviewProjection | SwiftUI版には相当概念なし（新規） |
| EventDetailOverviewAdapter | SwiftUI版には相当概念なし（新規） |

---

# End of EventDetailOverview Spec
