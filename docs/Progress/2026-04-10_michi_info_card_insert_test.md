# 2026-04-10 MichiInfoカード間挿入機能 Integration Test 全10件PASS

## 完了した作業
- test: MichiInfoカード間挿入機能 Integration Test 全10件PASS（TC-MCI-001〜010） (e48eb40)

- TC-MCI-007/009 FAIL の原因（`_onReloadRequested` ハンドラーに `isInsertMode: false` / `pendingInsertAfterSeq: null` のリセット未実装）を flutter-dev が修正
- 既存テストファイル `integration_test/michi_info_card_insert_test.dart` を使って再テスト実施
- TC-MCI-001〜010 全10件 PASS

## テスト結果

| シナリオID | シナリオ名 | 結果 |
|---|---|---|
| TC-MCI-001 | アイテムが1件以上ある状態でMichiInfoを開くとAmber FABが表示される | PASS |
| TC-MCI-002 | Amber FABをタップすると挿入モードになりインジケーターが表示される | PASS |
| TC-MCI-003 | 挿入モード中にFABを再タップすると通常モードに戻りインジケーターが消える | PASS |
| TC-MCI-004 | 挿入モード中にインジケーターをタップするとBottomSheetが表示される | PASS |
| TC-MCI-005 | BottomSheetをスワイプで閉じると挿入モードが継続する | PASS |
| TC-MCI-006 | BottomSheetで地点追加を選択するとMarkDetail新規作成画面に遷移する | PASS |
| TC-MCI-007 | Mark詳細を入力して保存するとタイムラインの指定位置にカードが挿入される | PASS |
| TC-MCI-008 | BottomSheetでリンク追加を選択するとLinkDetail新規作成画面に遷移する | PASS |
| TC-MCI-009 | Link詳細を入力して保存するとタイムラインの指定位置にカードが挿入される | PASS |
| TC-MCI-010 | 末尾インジケーターをタップしてMarkを追加・保存すると末尾にカードが追加される | PASS |

## 未完了・次回やること

- T-100〜103（カード間挿入機能）: テスト全件PASS → DONE
- T-120: 燃費更新機能 要件書作成
- その他残タスクはTASKBOARDを参照
