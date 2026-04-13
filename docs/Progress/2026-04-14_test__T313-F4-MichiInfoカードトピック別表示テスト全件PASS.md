# T-313 F-4 MichiInfoカード トピック別表示切り替え Integration Test 全件PASS

## 日付
2026-04-14

## 完了した作業

### T-313: MichiInfoカードトピック別表示 テスト実行
- テストファイル: `integration_test/michi_info_card_topic_view_test.dart`
- デバイス: iPhone 16 #2 (21CE8289-283C-40FD-9A1E-43B5439CFF35)
- ログ: `docs/TestLogs/2026-04-14_08-26_michi_info_card_topic_view.log`

### テスト結果

| シナリオID | テスト名 | 結果 |
|---|---|---|
| TC-MCV-001 | movingCostのMarkカードに日付が表示される | PASS |
| TC-MCV-001b | movingCostのMarkカードの日付テキストが空でない | PASS |
| TC-MCV-002 | movingCostのMarkカードにメンバーが表示されない | PASS |
| TC-MCV-003 | movingCostのMarkカードに累積メーターが表示される | PASS |
| TC-MCV-004 | movingCostのLinkカードに日付が表示される | PASS |
| TC-MCV-004b | movingCostのLinkカードの日付テキストが空でない | PASS |
| TC-MCV-005 | travelExpenseのMarkカードに名称が表示される | PASS |
| TC-MCV-005b | travelExpenseのMarkカードに日付も表示される | PASS |
| TC-MCV-006 | travelExpenseのMarkカードにメンバーが表示される | PASS |
| TC-MCV-006b | travelExpenseのMarkカードのメンバーテキストにメンバー名が含まれる | PASS |
| TC-MCV-007 | travelExpenseのLinkカードに日付が表示されない | PASS |

**合計: 11PASS / 0FAIL / 0SKIP**

### 備考
- 初回実行時にシミュレーター上で前回ビルドキャッシュ（event_add_skip_selection_test）が実行されたため、アプリをアンインストールして再実行した
- 再実行で全11件PASSを確認

## タスクボード更新
- T-311b: IN_PROGRESS → DONE
- T-312: TODO → DONE（承認済み）
- T-313: TODO → DONE

## 未完了タスク
- T-287a/b: UI-8 イベント追加スキップ遷移 実装・テストコード実装（IN_PROGRESS）
- T-288/289: UI-8 レビュー・テスト実行（TODO）
- T-295a/b: F-2 移動コスト収支バランス 実装・テストコード実装（IN_PROGRESS）
- T-296: F-2 レビュー（TODO）

## 次回セッションで最初にやること
- UI-8・F-2 の実装が完了したら reviewer によるレビューを実施する
- レビュー承認後、UI-8（T-289）・F-2（T-297 は DONE 済み）のテスト実行を行う
