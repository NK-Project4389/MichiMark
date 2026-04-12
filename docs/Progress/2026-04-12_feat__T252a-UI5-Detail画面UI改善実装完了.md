# 進捗記録: T-252a UI-5 Detail画面UI改善 実装完了

- **日付**: 2026-04-12
- **担当ロール**: flutter-dev
- **対応タスク**: T-252a

---

## 完了した作業
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

## 未完了

- T-252b: Detail画面UI改善 テストコード実装（tester担当）
- T-253: レビュー（reviewer担当）
- T-254: テスト実行（tester担当）

---

## 次回セッションで最初にやること

- T-252b のテストコード実装（tester ロールで `integration_test/detail_screen_ui_improvement_test.dart` を実装）
- TC-DSI-001〜015 の全15シナリオをカバーする
