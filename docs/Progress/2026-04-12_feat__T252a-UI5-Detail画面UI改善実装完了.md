# 進捗記録: T-252a UI-5 Detail画面UI改善 実装完了

- **日付**: 2026-04-12
- **担当ロール**: flutter-dev
- **対応タスク**: T-252a

---

## 完了した作業
- test(T-244): UI-4 PaymentInfo削除UIアイコン Integration Test 全件PASS（3PASS/0FAIL/0SKIP） (ab61e91)
- test(UI-2): TC-BTE-007c AppBarと重複するテキスト検索をコンテナ内に限定 (df63b9e)
- rules: Integration Test をシャード2並行構成に更新 (4513b82)
- docs: T-272/244/268 テスト再実行 IN_PROGRESS (925acac)
- test: T-234 UI-3 MichiInfo削除UI Integration Test 5PASS/2SKIP/0FAIL (11d6380)
- fix(test): TC-GPS-005/006 startApp クリーンアップ順序を修正 (6ebeb39)
- docs: T-214 DONE・T-272 BLOCKED（TC-GPS-005/006 調査中） (9412c27)
- test(UI-5): TC-DSI openLinkDetail ヘルパー修正 (d75880a)
- test(UI-1): TC-EDR startApp クリーンアップ修正 (5fe51d5)
- rules: Integration Test の全件実行に --concurrency=1 を必須化 (8a28eac)
- docs: コンテキスト最適化 - 重複ルール削除・コード例参照化 (9a9bb72)
- docs: コンテキスト最適化 - 重複ルール削除・コード例参照化 (9a9bb72)
- docs: T-271 合格・T-272 tester IN_PROGRESS (b66374f)
- docs: T-271 B-6 reviewer IN_PROGRESS (144a6af)
- docs: T-270a DONE — B-6 ガソリン支払者インラインFilterChip選択 実装完了 (ece2d0e)
- docs: T-269 B-6 Phase C Spec作成完了（FS-gas_payer_chip_selection_phaseC.md） (69e0edd)
- docs: B-6 Phase C タスク追加（T-269〜272） (cab6756)
- docs: T-233/253 レビュー合格・T-234/254 tester IN_PROGRESS (d4f7e8d)
- docs: T-233/253 レビュー合格・T-234/254 tester IN_PROGRESS (d4f7e8d)
- docs: T-213/223/243/267 レビュー合格・T-214/224/244/268 tester IN_PROGRESS (317a37a)
- docs: T-252a 進捗ファイル更新 (969d093)
- feat(UI-1): EventDetailPage 削除ボタン・ダイアログ・Delegate処理追加 (5153b5d)
- docs: T-212a/b T-232a T-242b T-266b DONE・Reviewer IN_PROGRESS 更新 (f1bbee7)
- feat: UI-1/UI-3/UI-6 実装・テストコード・flutter_slidable廃止 (fdb1167)
- test: T-222b BasicInfo タップ編集UI TC-BTE-001〜007 テストコード実装 (34ef71f)

### T-252a: MarkDetail/LinkDetail/PaymentDetail UI改善 実装

Spec `FS-detail_screen_ui_improvement.md` に基づき以下3ファイルを変更。

#### 変更内容（3画面共通）

1. **AppBar leading 廃止**
   - `leading: IconButton(...)` を削除
   - `automaticallyImplyLeading: false` を設定

2. **AppBar タイトル変更**
   - MarkDetail: `draft.markLinkName` が空なら `地点詳細`、あれば `地点詳細：{名称}` に変更
   - LinkDetail: `draft.markLinkName` が空なら `区間詳細`、あれば `区間詳細：{名称}` に変更
   - PaymentDetail: `支払詳細`（固定・変更なし）
   - AppBar title に `Key('markDetail_appBar_title')` 等を付与

3. **FloatingActionButton 削除 → フォーム末尾インラインボタン行に変更**
   - `floatingActionButton` プロパティを削除
   - `_XxxForm` に `isSaving` パラメータを追加
   - ListView 末尾に `Row(MainAxisAlignment.center)` でキャンセル・保存ボタンを横並び配置
   - キャンセル: `OutlinedButton` + `Key('markDetail_button_cancel')` 等
   - 保存: `ElevatedButton` + `Key('markDetail_button_save')` 等
   - `isSaving == true` 時は保存ボタンを `null`（非活性）にし `CircularProgressIndicator` を表示

#### 変更ファイル

- `flutter/lib/features/mark_detail/view/mark_detail_page.dart`
- `flutter/lib/features/link_detail/view/link_detail_page.dart`
- `flutter/lib/features/payment_detail/view/payment_detail_page.dart`

#### dart analyze 結果

今回変更した3ファイルに起因するエラー・警告はゼロ。
（既存の `event_detail_bloc.dart` / `michi_info_view.dart` のエラーは別タスク T-212a・T-232a のスコープ）

---

## T-254: テスト実行結果（2026-04-12）

### openLinkDetail ヘルパー修正
- `GestureDetector.at(1)` によるブラインドタップを削除
- シードデータのLink名 `東名高速` を `find.text().first` で探してタップする方式に変更
- `find.text('東名高速').evaluate().isEmpty` の場合はスクロールしてから探す
- 見つからない場合は `return false`（SKIP）

### テスト実行結果
- PASS: 18件 / FAIL: 0件 / SKIP: 0件
- ログ: `docs/TestLogs/2026-04-12_21-50_detail_screen_ui_improvement.log`

---

## 未完了

なし（T-252a〜T-254 すべて完了）

---

## 次回セッションで最初にやること

TASKBOARD の次の未着手タスクを確認して着手する。
