# 2026-04-13 UI-7・B-7・F-3・UI-9・UI-10・UI-11 Integration Test 全件PASS

## 完了した作業
- feat: impl-scheduleをユーザー指定時刻方式に変更 (c0fe5ee)
- feat: impl-scheduleスキル追加・orchestratorに自動スケジュールルール追加 (deab4c9)
- docs: UI-7/B-7/F-3/UI-9/UI-10/UI-11 全件PASS 進捗ファイル作成 (7a6608d)

### バグ修正

#### showCupertinoDialog<bool> 修正（UI-7起因）
- **対象ファイル**: `flutter/lib/features/michi_info/view/michi_info_view.dart`、`flutter/lib/features/payment_info/view/payment_info_view.dart`
- **問題**: `showCupertinoDialog<void>` ではキャンセルと削除で同じ `pop()` → 戻り値なし → 常に削除イベントが発火
- **修正**: `showCupertinoDialog<bool>` に変更。キャンセル: `pop(false)`、削除: `pop(true)`。`if (confirmed != true) return;` を追加

#### Container に Key を直接付与（UI-9起因）
- **対象ファイル**: `flutter/lib/features/overview/view/travel_expense_overview_view.dart`
- **問題**: Key が `_PerPaymentSettlementBlock`（StatelessWidget）自体に付いていたため、`find.byKey()` がカスタムウィジェットを返し `widget is Container` が false
- **修正**: `blockKey` フィールドを追加して内部の `Container` に直接 Key を渡す

#### 正しいイベントへのナビゲーション（UI-9起因）
- **対象ファイル**: `flutter/integration_test/payment_settlement_display_test.dart`
- **問題**: `openFirstEventDetail` が event-001（movingCost）を開いており travelExpense の概要タブが表示されない
- **修正**: `openEventDetailByName('富士五湖キャンプ')` で event-002（travelExpense）を直接指定

#### シードデータ復元（UI-11起因）
- **問題**: shard1（21CE8289）で過去のテスト実行時に ml-001 等が削除済み → 全件 SKIP
- **対処**: `xcrun simctl uninstall 21CE8289-283C-40FD-9A1E-43B5439CFF35 com.nkproject.michiMark` でアプリアンインストール → DB 再作成・シードデータ再投入

---

### Integration Test 実行結果

| Feature | テストファイル | PASS | FAIL | SKIP |
|---|---|---|---|---|
| B-7 削除後集計即時反映 | deletion_aggregation_update_test.dart | 6 | 0 | 0 |
| F-3 給油集計満タン文言 | fuel_full_tank_label_test.dart | 4 | 0 | 0 |
| UI-7 削除確認ダイアログ | delete_confirm_dialog_test.dart | 17 | 0 | 0 |
| UI-9 精算ブロックデザイン | payment_settlement_display_test.dart | 3 | 0 | 0 |
| UI-10 移動コスト名称非表示 | moving_cost_name_hidden_test.dart | 3 | 0 | 0 |
| UI-11 全選択/全解除ボタン | member_select_all_clear_test.dart | 7 | 0 | 0 |
| **合計** | | **40** | **0** | **0** |

---

## 未完了・次回やること

### 着手可能タスク（TODO）

| Feature | ID | 内容 |
|---|---|---|
| UI-8 | T-285〜T-289 | イベント追加ボタン 選択肢スキップ遷移（要件書から） |
| F-2 | T-293〜T-297 | 移動コスト集計 収支バランス追加（要件書から） |
| F-4 | T-309〜T-313 | MichiInfoカード トピック別表示切り替え部品（要件書から） |
| REL-1 | T-260 | AppStore 無料版リリース準備 |

### 次回セッション最初にやること

`docs/Tasks/TASKBOARD.md` を確認してユーザーに着手タスクを選んでもらう。
