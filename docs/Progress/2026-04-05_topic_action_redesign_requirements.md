# 2026-04-05 Topic・Action 設計再定義 要件書作成・デザインエージェント追加

## 完了した作業

### 要件書作成・更新（product-manager）

- `docs/Requirements/REQ-topic_action_redesign.md` 作成・更新
- タスクボードに Phase 5（T-050〜T-055）追加

### 要件内容サマリ（確定版）

| 要件ID | 概要 |
|---|---|
| REQ-001 | トピックはイベント新規作成時のみ選択可能（BasicInfoからTopic変更UI廃止・読み取り専用表示） |
| REQ-002 | アクションはTopicに紐づいて地点/区間ごとに固定表示（movingCost: 出発・到着のみ / travelExpense: なし） |
| REQ-003 | ActionSettingマスタ画面を一時非表示化（コードは残す） |
| REQ-004 | ActionDomainからfromStateを廃止 |
| REQ-005 | needsTransitionフラグ追加（false時はActionTimeLogのみ、状態遷移なし） |
| REQ-006 | Settings画面にイベント一覧へ戻るボタン実装 |
| REQ-007 | EventListカードをTopicカラーで色分け表示 |
| REQ-008 | EventDetail上部にトピック名ラベル＋テーマカラー表示 |
| REQ-009 | Settings画面でTopicの表示/非表示設定（TopicSetting追加） |

### デザインエージェント追加（orchestrator）

- `.claude/agents/designer.md` 作成
  - 役割: テーマカラー・UIデザイン提案・HTML形式レポート出力
  - 要件の叩き → product-managerレビュー → ユーザー確認フロー確立
- `docs/Design/` および `docs/Design/draft/` ディレクトリ作成
- `CLAUDE.md` 更新
  - designer 役割を役割一覧に追加
  - デザイン提案フローをルール化

---

## 未完了

- T-053: designer によるカード色・テーマカラーのデザイン提案（TODO）
- T-050: architect による Spec 作成（TODO・T-053のデザイン承認後が望ましい）
- T-051: flutter-dev による実装（T-050待ち）
- T-052: reviewer によるレビュー（T-051待ち）
- T-054〜T-055: カード色・テーマカラー実装（T-053承認待ち）

---

## 次回セッションで最初にやること

1. **T-053: designer にカード色・テーマカラーのデザイン提案を依頼**
   - REQ-007（EventListカード色分け）・REQ-008（EventDetailテーマカラー・トピック名）
   - HTML形式レポート → `docs/Design/` に出力
   - 要件の叩き → `docs/Design/draft/` に出力 → product-managerがレビュー → ユーザー確認
2. **T-050: architect に Spec 作成を依頼**（デザイン確定後 or 並行でREQ-001〜006の範囲のみ先行可）
   - 更新対象: Topic_Spec.md / ActionTime_Spec.md / ActionSetting_Spec.md / SettingsFeature_Spec.md
