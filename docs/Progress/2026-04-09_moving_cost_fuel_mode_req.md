# 進捗: 2026-04-09 セッション（movingCost燃費モード分離 要件書作成）

**日付**: 2026-04-09

---

## 完了した作業

### 1. PaymentInfo 追加ボタン テーマカラー修正（バグ修正）

- `PaymentInfoView` / `_PaymentInfoList` に `topicThemeColor: TopicThemeColor?` 追加
- `EventDetailPage` から `topicThemeColor` を渡すように変更
- reviewer承認・tester全件PASS

### 2. BasicInfo 燃費転記バグ修正

- `basic_info_bloc.dart` `_onTransSelected` で `kmPerGas.toString()` → `(kmPerGas / 10.0).toString()` に修正
- Integration Test（TC-BTF-001〜002）全件PASS

### 3. Git/Dart/Flutter コマンド永続許可追加

- `.claude/settings.json` の `permissions.allow` に `Bash(git *)` / `Bash(dart analyze*)` / `Bash(flutter build*)` / `Bash(flutter test*)` 追加
- 既存の `Bash(flutter test integration_test*)` は `flutter test*` に統合

### 4. movingCost 燃費モード分離 要件書作成（T-110/T-111完了）

- `docs/Requirements/REQ-moving_cost_fuel_mode.md` 作成
- **新規TopicType `movingCostEstimated`（移動コスト・燃費で推定）**: showFuelDetail=false、燃費・単価・支払者を概要タブに表示
- **既存`movingCost`変更**: 燃費・単価・支払者を概要タブから非表示、displayName="移動コスト（給油から計算）"
- **MarkDetail/LinkDetailへのガソリン支払者新規追加**: `MarkLinkDomain.gasPayer: MemberDomain?`、DBに`gas_payer_id`カラム追加
- タスクボード: T-110/T-111をDONE、T-112をTODOに更新

### 5. 仕様調査ルール追加

- `.claude/agents/orchestrator.md` 新規作成（仕様調査は設計書→Spec→コードの順）
- `.claude/rules/development.md` に「仕様調査の順序」セクション追加（全ロール共通ルール）

---

## 会話で確認された方針

### 燃費モード分離（案C採用）

- UIは「入力場所が2か所あって迷う」問題を、TopicTypeレベルで分離することで解消
- `movingCostEstimated`（燃費で推定）: 概要タブに燃費入力、MichiInfoの給油セクション非表示
- `movingCost`（給油から計算）: 概要タブの燃費非表示、MichiInfoの給油セクション表示＋ガソリン支払者追加

### 走行コスト割り勘ロジック（確認済み）

- 直上マーク = 前マーク
- メーター差分 = 現在のMarkのメーター − 前Markのメーター
- 現在Markのメーターが未入力 → LinkのdistanceValueを採用
- travelExpenseトピックの概要集計は汚染しない（movingCostのみ）

---

## 未完了 / 要対応

- T-112: 走行コスト割り勘 Spec作成（architect）← 次のタスク
- 既存テスト失敗（前セッションから継続）
  - TC-MAD-006/007（mark_addition_defaults_test.dart）
  - TS-03/04（michi_info_layout_test.dart）

---

## 次回セッションで最初にやること

1. `docs/Tasks/TASKBOARD.md` を確認してT-112（Spec作成）に着手
2. `architect` エージェントを使い、REQ-moving_cost_fuel_mode.md を元にSpecを作成する
3. 既存テスト失敗（TC-MAD-006/007、TS-03/04）を修正する
