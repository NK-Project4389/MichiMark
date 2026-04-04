# Aggregation Feature Specification

Platform: **Flutter / Dart**
Version: 1.0
Purpose: ActionTimeLogから算出した時間データと走行距離・費用データを組み合わせ、イベント単位・期間単位・フィルタ別で集計・表示する。

---

# 1. Feature Overview

## Feature Name

Aggregation

## Purpose

ActionTimeLogの時系列から移動・作業・休憩・滞留の各所要時間を算出し、走行距離・ガソリン代・経費と組み合わせて集計する。集計はイベント単位（EventDetailのOverview）と期間単位（AggregationPage）の2つの文脈で提供する。

## Scope

含むもの
- `AggregationResult` 値オブジェクト（Domain層）
- `AggregationFilter` 値オブジェクト（Domain層）
- `AggregationService`（Adapter/UseCase層）の責務定義
- `EventDetailOverview` BLoC設計（movingCost用集計Projectionを含む）
- `AggregationPage` BLoC設計（期間・フィルタ別集計画面）
- `EventRepository` への期間・フィルタ条件付きEvent取得メソッド追加
- DriftRepository拡張（schemaVersion +1 不要の範囲でクエリ追加のみ）

含まないもの
- CSVエクスポート
- グラフ・チャート表示
- 他ユーザーとの比較
- リアルタイム集計（push通知等）
- travelExpense用の収支バランス集計（Topic_SpecのTravelExpenseOverviewAdapterが担当）

---

# 2. 依存関係

| 依存先 | 内容 |
|---|---|
| ActionTime_Spec | `ActionTimeLog`・`ActionState` の定義に依存 |
| Topic_Spec | Overview BLoCのtopicConfig参照・TravelExpenseOverviewAdapterとの責務分離 |
| EventDomain | `tags`・`members`・`trans`・`topic` によるフィルタに依存 |
| MarkLinkDomain | 走行距離・給油量・ガソリン代の集計に依存 |
| PaymentDomain | 経費合計の集計に依存 |

---

# 3. TravelExpenseOverviewAdapterとの責務分離

Topic_SpecにはTravelExpenseOverviewAdapterが定義されている。本Specで定義するAggregationServiceとの責務は明確に分離する。

| 担当 | 責務 |
|---|---|
| `TravelExpenseOverviewAdapter`（Topic_Spec） | travelExpense用の収支バランス算出（PaymentDomainのsplitMembers均等配分・balanceの導出） |
| `AggregationService`（本Spec） | ActionTimeLogからの時間算出・MarkLink走行距離合計・給油合計・Payment経費合計・件数カウント等、全Topicで共通の集計ロジック |

OverviewBlocはtopicConfigを参照し、適切なAdapterを呼び分ける。集計ロジックをBLoC内に直接記述することは禁止する。

---

# 4. AggregationResult 値オブジェクト（Domain層）

集計結果を表すDomainオブジェクト。永続化しない（都度算出）。

## フィールド定義

| フィールド名 | Dart型 | NULL許容 | 説明 |
|---|---|---|---|
| `movingTime` | `Duration?` | ✅ | moving状態の所要時間合計。ActionTimeLogが不足する場合はnull |
| `workingTime` | `Duration?` | ✅ | working状態の所要時間合計（break_期間を除く）。ActionTimeLogが不足する場合はnull |
| `breakTime` | `Duration?` | ✅ | break_状態の所要時間合計。ActionTimeLogが不足する場合はnull |
| `waitingTime` | `Duration?` | ✅ | waiting状態の所要時間合計。ActionTimeLogが不足する場合はnull |
| `totalDistance` | `int` | ❌ | 全Linkの採用距離合計（km）。MarkLinkDomainの距離採用優先順位ルールに従う |
| `totalGasQuantity` | `int?` | ✅ | 全給油MarkLinkのgasQuantity合計（0.1L単位の10倍値）。給油レコードがない場合はnull |
| `totalGasPrice` | `int?` | ✅ | 全給油MarkLinkのgasPrice合計（円）。給油レコードがない場合はnull |
| `totalPayment` | `int?` | ✅ | 全PaymentのpaymentAmount合計（円）。Paymentがない場合はnull |
| `eventCount` | `int` | ❌ | 集計対象のイベント件数 |

設計方針:
- `Equatable` を継承する
- `const` コンストラクタを使用する
- UIを知らない

### null / 0 の使い分け

| 状況 | 値 |
|---|---|
| ActionTimeLogが0件のEvent | 時間系フィールド全てnull |
| ActionTimeLogが1件のみのEvent | 時間系フィールド全てnull（差分算出不可） |
| ActionTimeLogが2件以上だが特定状態のログがない | 該当状態のDurationは 0（Duration.zero）ではなくnull |
| 給油MarkLinkが存在しない | `totalGasQuantity`・`totalGasPrice` = null |
| Paymentが存在しない | `totalPayment` = null |

---

# 5. AggregationFilter 値オブジェクト（Domain層）

集計対象Eventを絞り込むフィルタ条件を表す値オブジェクト。

## フィールド定義

| フィールド名 | Dart型 | NULL許容 | 説明 |
|---|---|---|---|
| `dateRange` | `AggregationDateRange` | ❌ | 集計対象の期間指定（必須） |
| `tagIds` | `Set<String>` | ❌ | 絞り込むTagIdのSet。空Setはフィルタなし |
| `memberIds` | `Set<String>` | ❌ | 絞り込むMemberIdのSet。空Setはフィルタなし |
| `transId` | `String?` | ✅ | 絞り込むTransId。nullはフィルタなし |
| `topicId` | `String?` | ✅ | 絞り込むTopicId。nullはフィルタなし |

設計方針:
- `Equatable` を継承する
- `const` コンストラクタを使用する

## AggregationDateRange 定義

期間指定を表す sealed class。

| バリアント | フィールド | 説明 |
|---|---|---|
| `ThisMonth` | なし | 現在月の1日〜月末 |
| `LastMonth` | なし | 前月の1日〜月末 |
| `CustomRange` | `startDate: DateTime`, `endDate: DateTime` | ユーザー指定の任意期間 |

---

# 6. 状態所要時間の算出ロジック

算出ロジックはAggregationServiceに実装する。BLoC・Widgetへの直接実装は禁止。

## 算出手順

1. EventDomainの `actionTimeLogs` を `timestamp` の昇順でソートする
2. ログが1件以下の場合、時間系フィールドは全てnullとして返す
3. 連続する2つのログのペア `[log_n, log_n+1]` について:
   - 区間の状態 = `log_n` が記録するActionの `toState`
   - 区間の所要時間 = `log_n+1.timestamp - log_n.timestamp`
4. 各区間の所要時間を `ActionState` 別に加算する
5. 最後のログ以降の時間（イベント終了まで）は算出対象外とする

## 計算例

```
ActionTimeLogの時系列:
  09:00  出発（toState: moving）
  10:30  到着（toState: working）
  11:00  休憩開始（toState: break_）
  11:15  休憩終了（toState: working）
  13:00  出発（toState: moving）
  14:00  帰着（toState: waiting）

区間ごとの算出:
  09:00〜10:30  → moving状態  = 1h30m
  10:30〜11:00  → working状態 = 0h30m
  11:00〜11:15  → break_状態  = 0h15m
  11:15〜13:00  → working状態 = 1h45m
  13:00〜14:00  → moving状態  = 1h00m

合算結果:
  movingTime  = 1h30m + 1h00m = 2h30m
  workingTime = 0h30m + 1h45m = 2h15m
  breakTime   = 0h15m
  waitingTime = null（waiting状態の区間が存在しないため）
```

## 算出ルール

- 最初のログより前の時間は算出対象外
- 最後のログ以降の時間は算出対象外
- ログが1件のみの場合は全ての時間フィールドをnullとする
- 同一timestampのログが連続する場合は0秒の区間として扱う（Duration.zero を加算する）
- 特定状態の区間が1つも存在しない場合、その状態のフィールドはnull（Duration.zeroではない）

---

# 7. AggregationService（Adapter/UseCase層）

集計ロジックを一元管理するサービス。Domain・Repositoryに依存するが、UIに依存しない。

## 責務

- `EventDomain` 1件から `AggregationResult` を算出する（イベント単位集計）
- `List<EventDomain>` から `AggregationResult` を算出する（期間単位集計）
- MarkLinkDomainの距離採用優先順位ルールに従って走行距離を算出する

## メソッド定義（インターフェース定義のみ）

| メソッド名 | 入力 | 出力 | 説明 |
|---|---|---|---|
| `aggregateEvent` | `EventDomain event` | `AggregationResult` | イベント1件の集計 |
| `aggregateEvents` | `List<EventDomain> events` | `AggregationResult` | 複数Eventの集計（期間単位） |

設計方針:
- Adapter層（`flutter/lib/adapter/`）に配置する
- BLoCはDI（get_it）経由でAggregationServiceを注入して使用する
- BLoC内に集計ロジックを記述しない

---

# 8. EventRepository 拡張

期間・フィルタ条件でEventを取得するメソッドを追加する。

## 追加メソッド

| メソッド | 説明 |
|---|---|
| `fetchByDateRange(DateTime start, DateTime end)` | 指定期間内（`createdAt` が start〜end）のEventを取得する。`is_deleted = false` のみ |
| `fetchByFilter(AggregationFilter filter)` | AggregationFilterの全条件でフィルタしたEventを取得する |

## fetchByFilter のフィルタロジック

1. `dateRange` で期間を絞り込む
2. `tagIds` が空でない場合: EventのtagsにtagIdのいずれかが含まれるEventのみ取得する（OR条件）
3. `memberIds` が空でない場合: EventのmembersにmemberIdのいずれかが含まれるEventのみ取得する（OR条件）
4. `transId` が非nullの場合: EventのtransIdが一致するEventのみ取得する
5. `topicId` が非nullの場合: EventのtopicIdが一致するEventのみ取得する

設計方針:
- 既存の `EventRepository` abstract classに追加する
- drift実装は既存DriftEventRepositoryを拡張する
- クエリのフィルタ処理はDAO層（EventDao）に実装する
- DBスキーマ変更は不要（既存カラムへのWHERE句追加のみ）

---

# 9. EventDetailOverview BLoC設計

EventDetailのOverviewタブを担当するBLoC。Topic_SpecのOverview設計を引き継ぎ、Aggregation集計を組み込む。

## Feature責務

- EventDomainとTopicConfigを受け取り、TopicTypeに応じたProjectionを生成する
- movingCost用: AggregationServiceでイベント単位集計を行い、時間・距離・費用をProjectionに含める
- travelExpense用: TravelExpenseOverviewAdapter（Topic_Spec）を呼び出す（本Specの担当外）

## Draft Model（OverviewDraft）

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `eventId` | `String` | 対象イベントID |

Draftは参照用のみ。OverviewはEvent編集を行わない。

## Projection Model（OverviewProjection）

TopicConfigに応じて内容が切り替わる。

### MovingCostOverviewProjection フィールド

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `movingTimeLabel` | `String` | 移動時間の表示文字列（例: "2時間30分"、未算出は"---"） |
| `workingTimeLabel` | `String` | 作業時間の表示文字列 |
| `breakTimeLabel` | `String` | 休憩時間の表示文字列 |
| `waitingTimeLabel` | `String` | 滞留時間の表示文字列 |
| `totalDistanceLabel` | `String` | 総走行距離の表示文字列（例: "120km"） |
| `totalGasQuantityLabel` | `String` | 給油量の表示文字列（例: "30.0L"、なしは"---"） |
| `totalGasPriceLabel` | `String` | ガソリン代の表示文字列（例: "5,000円"、なしは"---"） |
| `totalPaymentLabel` | `String` | 経費合計の表示文字列（例: "3,000円"、なしは"---"） |

設計方針:
- `AggregationResult` のnullフィールドはProjection変換時に "---" に変換する
- Projection変換はAggregationAdapterまたはOverviewAdapter（Adapter層）が担当する
- BLoC内に表示文字列フォーマットロジックを記述しない

## State（OverviewState）

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `draft` | `OverviewDraft` | 対象イベントID |
| `topicConfig` | `TopicConfig` | 現在のTopicConfig（EventDetailBlocから伝播） |
| `movingCostProjection` | `MovingCostOverviewProjection?` | movingCost用Projection。算出完了後にnon-null |
| `travelExpenseProjection` | `TravelExpenseOverviewProjection?` | travelExpense用Projection（Topic_Spec参照） |
| `isLoading` | `bool` | 集計処理中フラグ |
| `errorMessage` | `String?` | エラーメッセージ |
| `delegate` | `OverviewDelegate?` | 遷移意図の通知 |

## BLoC Events

| Event名 | 発火タイミング | ペイロード | 説明 |
|---|---|---|---|
| `OverviewStarted` | Overview画面表示時 | `EventDomain event` | EventDomainを受け取り集計を実行する |
| `OverviewTopicConfigUpdated` | EventDetailBlocからTopicが変更されたとき | `TopicConfig config` | TopicConfigを更新し集計を再実行する |

## Delegate Contract

| Delegate名 | 通知先 | 説明 |
|---|---|---|
| （現時点ではNavigationなし） | - | Overviewは表示専用のため現フェーズでは遷移なし |

## データフロー

1. EventDetailBlocがOverviewBlocに `OverviewStarted` でEventDomainを渡す
2. OverviewBlocがTopicConfigを確認する
3. TopicConfigがmovingCost相当 → AggregationServiceを呼び出してAggregationResultを算出する
4. OverviewAdapter（Adapter層）がAggregationResult → MovingCostOverviewProjectionに変換する
5. TopicConfigがtravelExpense相当 → TravelExpenseOverviewAdapter（Topic_Spec）を呼び出す
6. Stateを更新してWidgetが再描画される

---

# 10. AggregationPage BLoC設計

期間・フィルタ別の集計専用画面。

## Feature責務

- AggregationFilterの選択・更新
- フィルタ条件でEventRepository.fetchByFilter()を呼び出す
- AggregationServiceで集計を実行する
- 集計結果をProjectionに変換してWidgetに渡す

## Draft Model（AggregationDraft）

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `filter` | `AggregationFilter` | 現在選択中のフィルタ条件 |
| `availableTags` | `List<TagDomain>` | 選択可能なTag一覧（TagRepositoryから取得） |
| `availableMembers` | `List<MemberDomain>` | 選択可能なMember一覧（MemberRepositoryから取得） |
| `availableTrans` | `List<TransDomain>` | 選択可能なTrans一覧（TransRepositoryから取得） |
| `availableTopics` | `List<TopicDomain>` | 選択可能なTopic一覧（TopicRepositoryから取得） |

## Projection Model（AggregationProjection）

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `eventCountLabel` | `String` | 集計対象イベント件数の表示文字列（例: "12件"） |
| `movingTimeLabel` | `String` | 移動時間合計の表示文字列（"---"含む） |
| `workingTimeLabel` | `String` | 作業時間合計の表示文字列 |
| `breakTimeLabel` | `String` | 休憩時間合計の表示文字列 |
| `totalDistanceLabel` | `String` | 総走行距離の表示文字列 |
| `totalGasPriceLabel` | `String` | ガソリン代合計の表示文字列 |
| `totalPaymentLabel` | `String` | 経費合計の表示文字列 |
| `filterSummaryLabel` | `String` | 現在のフィルタ内容のサマリー表示文字列（例: "今月 / タグ: 仕事"） |

## State（AggregationState）

| フィールド名 | Dart型 | 説明 |
|---|---|---|
| `draft` | `AggregationDraft` | フィルタ選択中状態 |
| `projection` | `AggregationProjection?` | 集計結果Projection。集計前はnull |
| `isLoading` | `bool` | 集計処理中フラグ |
| `errorMessage` | `String?` | エラーメッセージ |
| `delegate` | `AggregationDelegate?` | 遷移意図の通知 |

## BLoC Events

| Event名 | 発火タイミング | ペイロード | 説明 |
|---|---|---|---|
| `AggregationStarted` | 画面表示時 | なし | マスターデータを読み込み、初期フィルタ（今月）で集計を実行する |
| `AggregationDateRangeChanged` | 期間プリセットまたは任意期間の選択時 | `AggregationDateRange range` | フィルタのdateRangeを更新し集計を再実行する |
| `AggregationTagFilterChanged` | タグ選択・解除時 | `Set<String> tagIds` | フィルタのtagIdsを更新し集計を再実行する |
| `AggregationMemberFilterChanged` | メンバー選択・解除時 | `Set<String> memberIds` | フィルタのmemberIdsを更新し集計を再実行する |
| `AggregationTransFilterChanged` | Trans選択・解除時 | `String? transId` | フィルタのtransIdを更新し集計を再実行する |
| `AggregationTopicFilterChanged` | Topic選択・解除時 | `String? topicId` | フィルタのtopicIdを更新し集計を再実行する |
| `AggregationFilterCleared` | フィルタリセットボタン押下 | なし | フィルタを初期値に戻し集計を再実行する |

## Delegate Contract

| Delegate名 | 遷移先 | 説明 |
|---|---|---|
| （現時点ではNavigationなし） | - | Phase 1はAggregationPage内で完結する |

## データフロー

1. `AggregationStarted` でTagRepository・MemberRepository・TransRepository・TopicRepositoryからマスターデータを取得する
2. AggregationDraftに初期フィルタ（今月・全フィルタなし）をセットする
3. `EventRepository.fetchByFilter(filter)` でフィルタ済みEventListを取得する
4. `AggregationService.aggregateEvents(events)` で集計を実行しAggregationResultを得る
5. AggregationAdapter（Adapter層）がAggregationResult → AggregationProjectionに変換する
6. Stateを更新してWidgetが再描画される
7. フィルタ変更Event発火時は3〜6を繰り返す

---

# 11. Navigation

## Router変更方針

| パス | 対応Feature | 備考 |
|---|---|---|
| `/aggregation` | AggregationPage | 新規追加。BottomNavigationまたはSettings画面から遷移 |

遷移元・遷移方法は別途Router設計で確定する。AggregationBLocはNavigationを直接操作しない。

---

# 12. 永続化（Repository拡張）

DBスキーマ変更は不要。既存テーブル・カラムへのクエリ追加のみ。

## EventDao 拡張

| 追加クエリ | 説明 |
|---|---|
| `fetchByDateRange(start, end)` | `events.created_at` が期間内のレコードを全関連データと共に取得する |
| `fetchByFilter(filter)` | AggregationFilterの各条件をWHERE句・JOINで表現して取得する |

## パフォーマンス考慮

- 集計対象の目安は100件以下のEvent
- 初期実装はシンプルなクエリ + メモリ上での集計で対応する
- パフォーマンス問題が発生した場合に最適化を検討する（クエリ最適化・一括JOIN等）

---

# 13. ファイル構成

```
flutter/lib/
  domain/
    aggregation/
      aggregation_result.dart         -- AggregationResult値オブジェクト
      aggregation_filter.dart         -- AggregationFilter・AggregationDateRange値オブジェクト
  adapter/
    aggregation_service.dart          -- AggregationService（集計ロジック）
    overview_adapter.dart             -- AggregationResult → MovingCostOverviewProjection変換
    aggregation_adapter.dart          -- AggregationResult → AggregationProjection変換
  features/
    overview/
      bloc/
        overview_event.dart           -- OverviewEvent
        overview_state.dart           -- OverviewState
        overview_bloc.dart            -- OverviewBloc
      draft/
        overview_draft.dart           -- OverviewDraft
      projection/
        moving_cost_overview_projection.dart
    aggregation/
      bloc/
        aggregation_event.dart        -- AggregationEvent
        aggregation_state.dart        -- AggregationState
        aggregation_bloc.dart         -- AggregationBloc
      draft/
        aggregation_draft.dart        -- AggregationDraft
      projection/
        aggregation_projection.dart   -- AggregationProjection
      view/
        aggregation_page.dart         -- AggregationPage（Widget）
  repository/
    event_repository.dart             -- 既存拡張（fetchByDateRange・fetchByFilter追加）
    impl/
      drift/
        dao/
          event_dao.dart              -- 既存拡張（期間・フィルタクエリ追加）
        repository/
          drift_event_repository.dart -- 既存拡張（fetchByFilter実装追加）
      in_memory/
        in_memory_event_repository.dart  -- 既存拡張（fetchByFilter実装追加）
```

---

# 14. 受け入れ条件

- [ ] EventDetailのOverviewタブにActionTimeLogから算出した移動・作業・休憩時間が表示される
- [ ] ActionTimeLogが0件または1件のEventのOverviewは時間項目が"---"と表示される
- [ ] EventDetailのOverviewタブに走行距離合計・給油量合計・ガソリン代合計・経費合計が表示される
- [ ] AggregationPageで今月・先月を選択して集計結果を確認できる
- [ ] AggregationPageで任意の開始日〜終了日を指定して集計できる
- [ ] AggregationPageでタグ・メンバー・Trans・Topicでフィルタして集計できる
- [ ] 複数フィルタを組み合わせて集計できる（例: 今月 × 特定タグ）
- [ ] フィルタリセットで初期状態（今月・全フィルタなし）に戻る
- [ ] 算出ロジックが要件書の計算例と一致する（計算例は本Specのセクション6参照）
- [ ] 集計ロジックがAggregationService（Adapter層）に実装されており、BLoC・Widgetに書かれていない
- [ ] AggregationResultはDomainオブジェクトとして定義されており、UIに直接依存しない
- [ ] TopicがtravelExpenseのEventのOverviewではTravelExpenseOverviewAdapterが担当する（本Specの集計ロジックは呼ばれない）
- [ ] 100件以下のEventに対してUI表示まで1秒以内に完了する

---

# 15. SwiftUI版との対応

このFeatureはSwiftUI版には存在しない新規機能である。

---

# End of Aggregation Spec
