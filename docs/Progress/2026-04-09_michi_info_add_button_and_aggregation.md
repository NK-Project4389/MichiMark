# 進捗: 2026-04-09 セッション（MichiInfo追加ボタン改善・集計ページ整理）

**日付**: 2026-04-09

---

## 完了した作業

### 1. 移動コスト概要タブ 時間セクション削除（REQ-001）

- **対象**: `flutter/lib/features/overview/view/moving_cost_overview_view.dart`
- 時間セクション（移動時間・作業時間・休憩時間・滞留時間）を非表示
- 距離・費用セクションは維持
- MovingCostOverviewProjectionの計算ロジックは将来のトピック用に残存

### 2. MichiInfo追加FABカラー変更（REQ-002）

- **対象**: `flutter/lib/features/michi_info/view/michi_info_view.dart`
- `backgroundColor: widget.topicConfig.themeColor.primaryColor`
- `foregroundColor: Colors.white`
- movingCost → emeraldGreen（`#2E9E6B`）、travelExpense → amberOrange（`#E07B39`）
- TopicThemeColor.primaryColor は既存実装を流用（追加実装不要だった）

### 3. TopicConfig: allowLinkAdd → addMenuItems 配列化（REQ-003）

- **対象**: `flutter/lib/domain/topic/topic_config.dart` + 影響ファイル7件
- `AddMenuItemType enum { mark, link }` を新規定義
- `allowLinkAdd: bool` を `addMenuItems: List<AddMenuItemType>` に置き換え
- FAB動作の3パターン制御:
  - `[mark, link]` → ボトムシート表示（movingCost）
  - `[mark]` → 直接MarkDetail遷移（travelExpense）
  - `[link]` → 直接LinkDetail遷移（将来用）
  - `[]` → FAB非表示（将来用）
- 影響ファイル: michi_info_state / action_time_draft / link_detail_event / link_detail_state / event_detail_state / mark_detail_state / mark_detail_event

### 4. シードデータ「近所のドライブ」にトピック設定追加（REQ-004）

- `_event3` に `topic: seedTopics[0]`（movingCost）を明示追加

### 5. Integration Test（TC-MAB-001〜003 全件PASS）

- ファイル: `flutter/integration_test/michi_info_add_button_test.dart`
- TC-MAB-001: movingCostのFABタップでボトムシート表示（地点・区間の両方）
- TC-MAB-002: travelExpenseのFABタップで直接MarkDetail遷移
- TC-MAB-003: MovingCostOverviewViewに時間セクションが表示されないこと

### 6. TestFlight アップロード 1.0.0 (5)

- 上記変更をすべて含む
- objective_c.framework x86_64問題 → 前回arm64バイナリ差し替えで対処（恒久対策は未実施）

### 7. flutter test 自動許可設定

- `.claude/settings.json` に `Bash(flutter test integration_test*)` を永続許可追加

---

## 未完了 / 要対応

### 既存テスト失敗（UI変更に伴うテスト更新が必要）

| テストファイル | テストID | 原因 |
|---|---|---|
| `mark_addition_defaults_test.dart` | TC-MAD-006 | `IconButton.at(1)` でメンバー追加ボタンを探しているが UI 変更で順番が変わった |
| `mark_addition_defaults_test.dart` | TC-MAD-007 | AppBar の `Icons.check` 保存ボタンを探しているが FAB に変更済み |
| `michi_info_layout_test.dart` | TS-03, TS-04 | Mark/Link タップ後の遷移確認テキストが UI 変更で変わった可能性 |

### objective_c.framework の恒久対策

毎回ビルドのたびに x86_64 バイナリが混入する問題（手動で arm64 に差し替えが必要）。
Podfile または flutter build の設定で根本解決が必要。

---

## 次回セッションで最初にやること

1. `docs/Tasks/TASKBOARD.md` を確認してタスクを確認する
2. 既存テスト失敗を修正する（TC-MAD-006/007、TS-03/04）
3. objective_c.framework x86_64 問題の恒久対策を検討する
