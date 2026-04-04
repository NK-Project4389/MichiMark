# 2026-04-05 要件書・Feature Spec作成：Topic / ActionTime / Aggregation

## 完了した作業

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

## 未完了

- T-010〜T-012（Phase 2動作確認）は引き続きIN_PROGRESS

---

## 次回セッションで最初にやること

1. **reviewer に3つのSpecをレビューさせる**（Topic_Spec / ActionTime_Spec / Aggregation_Spec）
2. **Phase 2動作確認（T-010〜T-012）の継続**
