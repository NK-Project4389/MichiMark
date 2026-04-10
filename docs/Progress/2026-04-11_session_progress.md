# 2026-04-11 セッション進捗

## 完了した作業

### Phase 11: MichiInfo カード間挿入機能（T-099〜T-103）全完了
- T-100: CardInsert_Spec.md 作成
- T-101: 実装（FAB Amber化・挿入モード・インジケーター・BottomSheet・seq繰り上げ）
- T-102: レビュー全項目PASS
- T-103: Integration Test TC-MCI-001〜010 全10件PASS
  - バグ修正：保存後 `_onReloadRequested` で `isInsertMode` リセット漏れ → 修正済み

### Phase 13: 燃費更新機能（T-120〜T-124）全完了
- T-120: REQ-fuel_efficiency_update.md 作成（Trans選択時にkmPerGasを概要タブに反映）
- T-121: FuelEfficiencyUpdate_Spec.md 作成
- T-122: BasicInfoBloc._onTransSelected を修正（`.toStringAsFixed(1)` + `isEstimatedMode` チェック）
- T-123: レビュー全項目PASS
- T-124: TC-FEU-001/003 PASS、TC-FEU-002 SKIP（kmPerGas=nullのTransをUIから作成不可）

### その他
- 許可設定追加: `Bash(xcrun *)` / `Bash(sqlite3 *)` を `.claude/settings.json` に追加

## 未完了・次回やること

### タスクボード残タスク
- Phase 13 以降のタスクボードを確認する（T-120〜124 は全DONE）
- 他に残タスクがあれば TASKBOARD.md を参照

### 次回最初にやること
1. `git pull`
2. `docs/Tasks/TASKBOARD.md` 確認
3. 残タスクに着手
