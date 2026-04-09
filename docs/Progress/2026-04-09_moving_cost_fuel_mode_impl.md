# 進捗: 2026-04-09 セッション（MovingCostFuelMode 実装完了・TF 1.0.0(6)）

**日付**: 2026-04-09

---

## 完了した作業

### 1. オーケストレーター ルール追加（仕様調査順序）

- `.claude/agents/orchestrator.md` 新規作成
- `.claude/rules/development.md` に「仕様調査の順序（全ロール共通）」セクション追加
- ルール: Spec → 設計憲章 → 要件書 → コードの順で確認する（コードから仕様を推測することは禁止）

### 2. MovingCostFuelMode 要件書作成（T-110/T-111 DONE）

- `docs/Requirements/REQ-moving_cost_fuel_mode.md` 作成
- movingCostEstimated（燃費推定モード）とmovingCost（給油実績モード）をTopicTypeレベルで分離
- MarkDetail/LinkDetailへのガソリン支払者（gasPayer）新規追加仕様を定義

### 3. MovingCostFuelMode Spec作成（T-112 DONE）

- `docs/Spec/Features/MovingCostFuelMode_Spec.md` 作成
- schemaVersion 3→4（gas_payer_id カラム追加）
- テストシナリオ TC-FCM-001〜008 定義

### 4. MovingCostFuelMode 実装（T-113 DONE）

主な変更内容：
- `TopicType.movingCostEstimated` 追加（全switch箇所に明示追加）
- `TopicConfig.movingCost`: showKmPerGas/showPricePerGas/showPayMember → false、displayName変更
- `TopicConfig.movingCostEstimated`: 新規定義（showFuelDetail=false、燃費系フラグ=true）
- `MarkLinkDomain.gasPayer: MemberDomain?` フィールド追加
- drift schemaVersion 4・mark_links に gas_payer_id カラム追加・マイグレーション追加
- MarkDetail/LinkDetail: ガソリン支払者 Draft/Event/State/Delegate/Bloc/UI 追加
- シードデータ: movingCostEstimated サンプルイベント追加

### 5. MovingCostFuelMode レビュー・テスト（T-114/T-115 DONE）

- reviewer 承認（全項目PASS）
- tester: TC-FCM-001〜008 全8件PASS

### 6. TestFlight 1.0.0 (6) アップロード

- MovingCostFuelMode を含むビルドをアップロード
- objective_c.framework の x86_64→arm64 差し替えを実施（既知の問題）
- testflightスキル（`~/.claude/skills/testflight/skill.md`）にStep 2.5としてルール化

### 7. 許可設定追加

- `.claude/settings.json`（MichiMark・NomikaiShare 両方）に `Bash(dart run build_runner*)` 追加

---

## 未完了 / 要対応

- 既存テスト失敗（継続中）
  - TC-MAD-006/007（mark_addition_defaults_test.dart）
  - TS-03/04（michi_info_layout_test.dart）
- T-099〜T-103（Phase 11: カード挿入機能）— BLOCKED
- T-120〜（Phase 13: 燃費更新機能）— TODO

---

## 次回セッションで最初にやること

1. `docs/Tasks/TASKBOARD.md` を確認
2. 既存テスト失敗（TC-MAD-006/007、TS-03/04）を修正する
3. Phase 11（T-100: カード挿入機能 Spec作成）を進める
