# 2026-04-05 Topic・Action 設計再定義 要件書作成

## 完了した作業

### 要件書作成（product-manager）

- `docs/Requirements/REQ-topic_action_redesign.md` 作成
- タスクボードに Phase 5（T-050〜T-052）追加

### 要件内容サマリ

| 要件ID | 概要 |
|---|---|
| REQ-001 | トピックはイベント新規作成時のみ選択可能（BasicInfoからTopic変更UI廃止） |
| REQ-002 | アクションはTopicに紐づいて地点/区間ごとに固定表示（fromState照合廃止） |
| REQ-003 | ActionSettingマスタ画面を一時非表示化 |
| REQ-004 | ActionDomainからfromStateを廃止 |
| REQ-005 | needsTransitionフラグ追加（false時はActionTimeLogのみ、状態遷移なし） |
| REQ-006 | Settings画面にイベント一覧へ戻るボタン実装 |

---

## 未完了

- T-050: architect による Spec 作成（未着手）
- T-051: flutter-dev による実装（T-050待ち）
- T-052: reviewer によるレビュー（T-051待ち）

---

## 次回セッションで最初にやること

1. **architect に T-050 を依頼**（REQ-topic_action_redesign.md を読み込んでSpec作成）
   - 対象Spec: Topic_Spec.md（更新）、ActionTime_Spec.md（更新）、ActionSetting_Spec.md（更新）、SettingsFeature_Spec.md（更新）
2. **Spec承認後 flutter-dev に T-051 を依頼**
