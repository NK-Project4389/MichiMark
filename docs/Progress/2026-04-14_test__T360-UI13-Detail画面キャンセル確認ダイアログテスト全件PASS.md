# T-360 UI-13: Detail画面キャンセル確認ダイアログ テスト実行 完了

## 作業日
2026-04-14

## 作業内容

### 実行テスト
`integration_test/detail_cancel_confirmation_test.dart`（TC-DCC-001〜012）

### 結果
**16PASS / 0FAIL / 0SKIP**

| シナリオID | テスト名 | 結果 |
|---|---|---|
| TC-DCC-001 | MarkDetail — 変更なしでキャンセルするとダイアログが出ない | PASS |
| TC-DCC-002 | MarkDetail — 変更してキャンセルするとダイアログが出る | PASS |
| TC-DCC-002b | MarkDetail — ダイアログにタイトル「変更を破棄しますか？」が表示される | PASS |
| TC-DCC-002c | MarkDetail — ダイアログに「破棄する」ボタンが表示される | PASS |
| TC-DCC-002d | MarkDetail — ダイアログに「編集を続ける」ボタンが表示される | PASS |
| TC-DCC-003 | MarkDetail — ダイアログで「破棄する」を選択すると前画面へ戻る | PASS |
| TC-DCC-004 | MarkDetail — ダイアログで「編集を続ける」を選択すると画面に留まる | PASS |
| TC-DCC-005 | LinkDetail — 変更なしでキャンセルするとダイアログが出ない | PASS |
| TC-DCC-006 | LinkDetail — 変更してキャンセルするとダイアログが出る | PASS |
| TC-DCC-007 | LinkDetail — ダイアログで「破棄する」を選択すると前画面へ戻る | PASS |
| TC-DCC-008 | LinkDetail — ダイアログで「編集を続ける」を選択すると画面に留まる | PASS |
| TC-DCC-009 | PaymentDetail — 変更なしでキャンセルするとダイアログが出ない | PASS |
| TC-DCC-010 | PaymentDetail — 金額を入力してキャンセルするとダイアログが出る | PASS |
| TC-DCC-011 | PaymentDetail — ダイアログで「破棄する」を選択すると前画面へ戻る | PASS |
| TC-DCC-012 | PaymentDetail — ダイアログで「編集を続ける」を選択すると画面に留まる | PASS |

ログ: docs/TestLogs/2026-04-14_09-18_detail_cancel_confirmation.log

### テストコード修正内容（1回目失敗 → 修正 → 全件PASS）

#### 問題1: MarkDetail/LinkDetail系（TC-DCC-001〜008）が全件SKIP
- **原因**: シードデータのイベント「箱根日帰りドライブ」は移動コスト可視化トピック（`showNameField: false`）のため、MichiInfoカードに名称テキスト（「大涌谷」「東名高速」）が表示されない
- **修正**: `find.text('大涌谷')` → `Key('michiInfo_text_markDate_ml-005')` の祖先GestureDetectorをタップ、`find.text('東名高速')` → `Key('michiInfo_text_linkDate_ml-002')` に変更
- **追加修正**: `openNewMarkDetail` にFABタップ後のBottomSheet「地点を追加」（`michiInfo_button_addMark`）タップ処理を追加
- **Draft変更方法**: `markDetail_field_name` / `linkDetail_field_name` が表示されない場合、累積メーター / 走行距離フィールド（NumericInputRow）をタップしてカスタムキーパッドで値を入力する方式に変更

#### 問題2: PaymentDetail系（TC-DCC-010〜012）が FAIL
- **原因**: `tester.enterText(amountField, '1000')` が `Bad state: No element` エラー。`paymentDetail_field_amount`（NumericInputRow）はシステムキーボード非使用の独自実装のため、内部に `EditableText` が存在しない
- **修正**: `numeric_input_tap_支払金額` Key でカスタムキーパッドを起動 → `keypad_digit_1`, `keypad_digit_0`, `keypad_digit_0`, `keypad_digit_0`, `keypad_confirm` をタップして「1000」を入力

## タスクボード更新
- T-360: `DONE`

## 次回セッションで最初にやること
- UI-12（未保存新規イベント自動削除）テスト実行（T-356）が `TODO` のまま
- T-295a/T-295b が `IN_PROGRESS` 状態のまま（別セッションで作業中の可能性あり、要確認）
