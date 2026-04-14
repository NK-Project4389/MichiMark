# B-13 / B-14 テスト実行 全件PASS

## 作業日
2026-04-14

## 担当ロール
tester

## 完了した作業

### B-13: BasicInfo マスタ非表示フィルタ（T-380）

- テストファイル: `flutter/integration_test/basic_info_master_hidden_filter_test.dart`
- 実行デバイス: iPhone 16 #1 / UDID: DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6
- ログ: `docs/TestLogs/2026-04-14_13-24_basic_info_master_hidden_filter.log`

#### テスト結果

| シナリオID | テスト名 | 結果 |
|---|---|---|
| TC-BHF-001 | 非表示メンバーがBasicInfoメンバー候補に表示されないこと | PASS |
| TC-BHF-002 | 表示中メンバーはBasicInfoメンバー候補に表示されること | PASS |
| TC-BHF-003 | 非表示タグがBasicInfoタグ候補に表示されないこと | PASS |
| TC-BHF-004 | 非表示TransがBasicInfoのTrans選択肢に表示されないこと | PASS |

**結果: 4PASS/0FAIL/0SKIP**

### B-14: FAB再押し不可バグ（T-383）

- テストファイル: `flutter/integration_test/event_list_fab_repress_test.dart`
- 実行デバイス: iPhone 16 #1 / UDID: DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6
- ログ: `docs/TestLogs/2026-04-14_13-24_event_list_fab_repress_retry6.log`

#### テスト結果

| シナリオID | テスト名 | 結果 |
|---|---|---|
| TC-EFR-001 | FAB押下→トピック未選択→キャンセル後にFABが再押し可能であること | PASS |
| TC-EFR-002 | FAB押下→キャンセル→再度FAB押下→トピック選択→イベント詳細に遷移できること | PASS |

**結果: 2PASS/0FAIL/0SKIP**

#### テストコード修正内容

- `isTopicSelectionSheetVisible` の判定を修正
  - 旧: トピック名テキスト（「移動コスト（給油から計算）」など）の存在で判定
  - 新: `BottomSheet` ウィジェット存在 + 「トピックを選択」テキストの両方で判定
  - 理由: EventListPage のイベントカードにもトピック名が表示されるため、シート外のテキストでの判定が誤判定を引き起こしていた
- `cancelTopicSheet` を `tapAt(200, 100)` に変更（画面上部タップで ModalBarrier 経由クローズ）
- TC-EFR-002 のトピック選択タップを `find.descendant(of: BottomSheet, ...)` で特定
  - 理由: `find.text('移動コスト...')` が複数ヒットし `.first` がイベントカードのテキストをポイントしていた

## タスクボード更新

- T-378b/T-378a: `IN_PROGRESS` → `DONE`
- T-379: `TODO` → `DONE`（レビュー承認確認）
- T-380: `TODO` → `DONE`（4PASS）
- T-381a/T-381b: `IN_PROGRESS` → `DONE`
- T-382: `TODO` → `DONE`（レビュー承認確認）
- T-383: `TODO` → `DONE`（2PASS）

## 次回セッションで最初にやること

- B-15（T-384〜386）が `IN_PROGRESS` 状態
- 燃費推定 経費合計フォールバックのテスト実行が残っている
- タスクボードで `B-15` の状況を確認してから着手する
