# 2026-04-05 要件書作成：Topic / ActionTime / Aggregation

## 完了した作業

### Topic_Requirements.md 作成

- Topicの概念定義（イベントの用途カテゴリ）
- Phase 1: 固定2種（移動コスト可視化・旅費可視化）の表示項目・Overview定義
- Phase 2・3の段階的拡張方針を記載
- TopicDomain（新規）・TopicType enum の定義
- EventDomainへの `topic: TopicDomain?` 追加を定義

### ActionTime_Requirements.md 作成

- ActionTimeの概念定義（Action = 状態遷移トリガー）
- ActionState enum（waiting / moving / working / break_）
- ActionTimeLog エンティティ定義（EventIDに直接紐づく）
- ActionDomainへの追加フィールド（fromState / toState / isToggle / togglePairId）
- デフォルトAction 5種の定義（出発・到着・帰着・休憩開始・休憩終了）
- 休憩トグルUI・設定画面要件を定義

### Aggregation_Requirements.md 作成

- 集計軸3種の定義（イベント単位・期間単位・タグ別）
- ActionTimeLogからの状態所要時間算出ロジック（計算例付き）
- AggregationResult 値オブジェクト定義
- AggregationPage（新規画面）要件定義
- Topic・ActionTimeへの依存関係を明記

---

## 未完了

- T-010〜T-012（Phase 2動作確認）は引き続きIN_PROGRESS

---

## 次回セッションで最初にやること

1. **3要件書のレビュー**（ユーザーと内容確認・修正）
2. **architect に各要件書からFeature Spec作成を依頼**（Topic → ActionTime → Aggregation の順）
3. **Phase 2動作確認（T-010〜T-012）の継続**（要件書と並行でもOK）
