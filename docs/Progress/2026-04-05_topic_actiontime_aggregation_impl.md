# 2026-04-05 Topic / ActionTime / Aggregation / EventDetailOverview 実装・レビュー完了

## 完了した作業

### 設計書レビュー（reviewer）

- Topic_Spec.md：【要修正】→ architect が修正 → 再レビューで【承認】
  - EventDetailBlocの子Bloc管理を一方向pushに変更
  - BasicInfoBlocからTopicRepositoryのDI注入を削除（EventDetailBlocに移管）
  - Delegate通信のBlocListener経由を明記
  - EventDetailOverview_Spec.mdへの参照を追加
- ActionTime_Spec.md：【OK】
- Aggregation_Spec.md：【OK】
- EventDetailOverview_Spec.md：【OK】（新規作成・レビュー済み）

### EventDetailOverview_Spec.md 新規作成（architect）

- Topic_Spec §12 と Aggregation_Spec §9 に分散していたOverview定義を一本化
- movingCost vs travelExpense の切り替え責務を本Specに集約
- TopicConfigフラグによる切り替え（TopicType直接比較禁止）を明文化

### 実装（flutter-dev）

- **Topic Feature**: TopicDomain・TopicConfig・BasicInfo拡張・EventDetailBloc伝播
- **ActionTime Feature**: ActionState・ActionTimeLog・ActionTimeAdapter・ActionTimeBloc
- **Aggregation Feature**: AggregationService・AggregationResult・AggregationBloc
- **EventDetailOverview Feature**: EventDetailOverviewBloc・Adapter・表示切り替え
- **OverviewStarted 発火問題修正**: EventDetailStateにcachedEventを追加・BlocListenerでOverviewStarted発火

### レビュー指摘修正（flutter-dev）

1. **schemaVersion 2 マイグレーション**
   - `action_time_logs` テーブル新規追加
   - `actions` テーブルに fromState / toState / isToggle / togglePairId カラム追加
   - `onUpgrade` で ALTER TABLE / CREATE TABLE 実装

2. **ActionSetting Feature 拡張**
   - Draft / Event / Bloc / Projection / View すべてに新フィールド追加
   - ActionState ドロップダウン・トグルUI実装

3. **MarkDetail / LinkDetail への TopicConfig 伝播**
   - PaymentInfo → PaymentDetail と同じパターンで実装
   - MichiInfoBloc が Delegate に topicConfig を含める
   - MichiInfoView が navigate 時に MarkDetailArgs / LinkDetailArgs で extra に渡す
   - router で extra から TopicConfig を取り出して Bloc に渡す

---

## 未完了

- T-010〜T-012（Phase 2動作確認）は引き続きIN_PROGRESS

---

## 次回セッションで最初にやること

1. **flutter run で動作確認**（Topic選択→表示制御・Overview集計・ActionTime記録が正しく動くか）
2. **Phase 2動作確認（T-010〜T-012）の継続**
