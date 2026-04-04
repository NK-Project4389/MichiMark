# 2026-04-05 要件書・Feature Spec作成：Topic / ActionTime / Aggregation

## 完了した作業
- docs: 進捗ファイルの末尾ゴミ行を除去 (daa5c56)
- fix(hooks): push時の進捗追記を完了した作業セクション直下に挿入するよう修正 (09e0593)

### Topic_Requirements.md 作成・詳細化

- Topicの概念定義（イベントの用途カテゴリ）
- Phase 1: 固定2種（移動コスト可視化・旅費可視化）の表示制御を詳細決定
  - 旅費可視化：累積メーター・給油Detail・BasicInfoの燃費系・Link追加ボタンを完全非表示
  - 移動コスト可視化：PaymentInfoタブを表示（高速代等）
- 旅費Overview：メンバー別トータルコスト・収支バランス（全員合計=0）を定義
- splitMembers空 = 支払者1人負担ルールを明記
- TopicDomain（新規）・TopicType enum の定義

### ActionTime_Requirements.md 作成

- ActionTimeの概念定義（Action = 状態遷移トリガー）
- ActionState enum（waiting / moving / working / break_）
- ActionTimeLog エンティティ定義（EventIDに直接紐づく・MarkLink非依存）
- ActionDomainへの追加フィールド（fromState / toState / isToggle / togglePairId）
- デフォルトAction 5種の定義（出発・到着・帰着・休憩開始・休憩終了）
- 休憩トグルUI・設定画面要件を定義

### Aggregation_Requirements.md 作成

- 集計軸3種の定義（イベント単位・期間単位・タグ別）
- ActionTimeLogからの状態所要時間算出ロジック（計算例付き）
- AggregationResult 値オブジェクト定義
- AggregationPage（新規画面）要件定義
- Topic・ActionTimeへの依存関係を明記

### Topic_Spec.md 作成

- TopicConfig値オブジェクト（表示フラグの集合体）で表示制御を抽象化
- TopicConfigの伝播：BasicInfoBloc → EventDetailBloc → 子Bloc（Delegate経由）
- 収支バランス算出：TravelExpenseOverviewAdapter（Adapter層）に集約
- Topic未設定 → movingCostにフォールバック（TopicConfig.fromTopicTypeで一元管理）

### ActionTime_Spec.md 作成

- ActionState enum・ActionTimeLog Domain・ActionDomain拡張を定義
- 状態導出ロジック：ActionTimeAdapter（Adapter層）に集約
- 休憩トグルはBLoC内でcurrentStateを見て開始/終了を判断
- DriftRepository schemaVersion 2 への移行（actions 4カラム追加 + action_time_logs テーブル新規）

### Aggregation_Spec.md 作成

- AggregationService（Adapter層）に全Topic共通集計ロジックを集約
- TravelExpenseOverviewAdapter（Topic_Spec）との責務分離を明確化
- ActionTimeLogが0〜1件の場合は時間系フィールドnull（0分と未算出を区別）
- Repository拡張はクエリ追加のみ（schemaVersion変更不要）

---

### iOS アプリアイコン設定

- SwiftUI プロジェクト（`MichiMark/Assets.xcassets`）のアイコン画像を Flutter iOS 側に反映
- 不足サイズ（20x20@1x・76x76・83.5x83.5）は sips で 1024px 元画像から生成

### バグ修正：イベント詳細から一覧に戻れない

- `event_list_page.dart` の `context.go()` → `context.push()` に変更
- `go` はスタックを置き換えるため `pop()` できなかった

---

---

### Topic / ActionTime / Aggregation / EventDetailOverview Feature 実装

**新規ファイル（Flutter実装）**

- `domain/topic/topic_domain.dart` — TopicDomain + TopicType enum
- `domain/topic/topic_config.dart` — TopicConfig 値オブジェクト
- `domain/action_time/action_state.dart` — ActionState enum
- `domain/action_time/action_time_log.dart` — ActionTimeLog domain entity
- `domain/aggregation/aggregation_result.dart` — AggregationResult
- `domain/aggregation/aggregation_filter.dart` — AggregationFilter + sealed AggregationDateRange
- `repository/topic_repository.dart` — TopicRepository interface
- `repository/impl/in_memory/in_memory_topic_repository.dart` — InMemory実装
- `adapter/selection_adapter.dart` — fromTopics追加
- `adapter/aggregation_service.dart` — AggregationService
- `adapter/event_detail_overview_adapter.dart` — MovingCostOverviewAdapter
- `adapter/travel_expense_overview_adapter.dart` — TravelExpenseOverviewAdapter
- `adapter/aggregation_adapter.dart` — AggregationAdapter
- `adapter/action_time_adapter.dart` — ActionTimeAdapter
- `features/overview/` — EventDetailOverview Feature（BLoC/View/Projection全体）
- `features/action_time/` — ActionTime Feature（BLoC/View全体）
- `features/aggregation/` — Aggregation Feature（BLoC/View全体）

**変更ファイル（既存拡張）**

- `domain/transaction/event/event_domain.dart` — topic/actionTimeLogs フィールド追加
- `domain/master/action/action_domain.dart` — fromState/toState/isToggle/togglePairId 追加
- `repository/event_repository.dart` — ActionTimeLog CRUD + 集計クエリ追加
- `repository/impl/in_memory/in_memory_event_repository.dart` — 新メソッド実装
- `repository/impl/in_memory/seed_data.dart` — seedTopics (movingCost/travelExpense) 追加
- `repository/impl/drift/repository/drift_event_repository.dart` — 新メソッドスタブ追加（TODO）
- `features/basic_info/` — Topic選択UI・topicConfig表示制御を追加（draft/state/event/bloc/view 全体）
- `features/mark_detail/` — topicConfig受け取り・showMeterValue/showFuelDetailで表示制御
- `features/link_detail/` — topicConfig受け取り・showLinkDistance/showFuelDetailで表示制御
- `features/michi_info/` — topicConfig受け取り・allowLinkAddでLink追加ボタン制御
- `features/event_detail/` — TopicRepository注入・topicConfig管理・子Bloc伝播・OverviewBloc統合
- `features/selection/` — eventTopic type追加・TopicRepository注入
- `app/di.dart` — TopicRepository・AggregationService 登録
- `app/router.dart` — EventDetailBloc/SelectionBlocにTopicRepository追加・/aggregation route追加

**アーキテクチャ上の設計判断**

- BasicInfoTopicChangedDelegate → _EventDetailScaffoldInner のBlocListenerが受け取り EventDetailTopicChanged を EventDetailBloc に送信
- EventDetailAvailableTopicsDelegate → 同BlocListenerが BasicInfoBloc に BasicInfoAvailableTopicsReceived を送信
- EventDetailTopicConfigPropagateDelegate → MichiInfoBloc に MichiInfoTopicConfigUpdated を送信（MarkDetail/LinkDetailは別ルート生成のため未対応・TODO）
- OverviewBlocはEventDetailPage内のMultiBlocProviderで生成（EventDetailOverviewPageが直接利用）
- MarkDetail/LinkDetailへのtopicConfig伝播は別ルート生成のためEventDetailからの直接送信不可（別セッションで対応）

### OverviewBloc OverviewStarted 発火問題の解決

- `EventDetailLoaded`に`cachedEvent: EventDomain?`フィールドを追加
- `EventDetailBloc._onStarted`・`_onSaveRequested`でキャッシュをセット
- `_EventDetailScaffoldInner`に第3のBlocListenerを追加:
  - タブ選択でoverview選択時 → `OverviewStarted(event, topicConfig)`を発火
  - `EventDetailTopicConfigPropagateDelegate`時 → `OverviewTopicConfigUpdated(config, event)`も同時発火

### Warning修正

- `action_time_bloc.dart:94` - 未使用ローカル変数`targetActionState`を除去（コメントに統合）
- `overview_bloc.dart` - 未使用import `topic_domain.dart`を除去
- `event_detail_overview_page.dart` - 未使用import 3つを除去

## 未完了

- MarkDetail/LinkDetailBloc へのtopicConfig伝播（別ルートのため現セッション未対応）
- Drift スキーマ移行（schemaVersion 2: topics表・events.topic_id・action_time_logs表・actionsカラム追加）
- ActionSetting拡張（fromState/toState/isToggle UI）

---

## 次回セッションで最初にやること

1. **動作確認・E2Eテスト**（Topic選択→表示制御・Overview集計が正しく機能するか）
2. **MarkDetail/LinkDetailへのtopicConfig伝播**（別ルートのBlocへの伝播設計）
3. **Drift スキーマ移行**（schemaVersion 2）
