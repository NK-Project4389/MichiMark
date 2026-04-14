# Feature Spec: Detail画面 キャンセル確認ダイアログ

**Feature ID**: UI-13
**要件書**: docs/Requirements/REQ-detail_cancel_confirmation.md
**作成日**: 2026-04-14
**ステータス**: Draft

---

## 1. Feature Overview

### Feature Name

DetailCancelConfirmation（Detail画面キャンセル確認ダイアログ）

### Purpose

MarkDetail・LinkDetail・PaymentDetail でキャンセルボタンを押した際、Draft と保存済み Snapshot（初期 Draft）が異なる場合に CupertinoAlertDialog を表示し、誤操作による入力内容の消失を防ぐ。

### Scope

**含むもの**
- MarkDetail キャンセルボタン押下時の差分判定
- LinkDetail キャンセルボタン押下時の差分判定
- PaymentDetail キャンセルボタン押下時の差分判定
- 差分あり: CupertinoAlertDialog の表示
- 「破棄する」→ Draft を初期スナップショットにリセットして Dismiss
- 「編集を続ける」→ ダイアログを閉じて編集継続

**含まないもの**
- BasicInfo（概要タブ）: インライン編集のため対象外
- システムのスワイプバック: 対象外（既存挙動を維持）

---

## 2. Feature Responsibility

MarkDetailBloc・LinkDetailBloc・PaymentDetailBloc それぞれが以下を担当する。

- 画面オープン時の初期 Draft を `initialDraft`（スナップショット）として State に保持
- キャンセルボタン押下時に `currentDraft == initialDraft` を Equatable で比較
- 一致する場合: そのまま `DismissDelegate` を emit
- 異なる場合: `ShowCancelConfirmDialogDelegate` を emit → Page が CupertinoAlertDialog を表示
- 「破棄する」選択時: `draft = initialDraft` に戻して `DismissDelegate` を emit
- 「編集を続ける」選択時: State 変更なし（Dialog を閉じるのみ）

---

## 3. State Structure

### 各 Loaded State への追加フィールド

**MarkDetailLoaded・LinkDetailLoaded・PaymentDetailLoaded 共通**

| フィールド | 型 | 説明 |
|---|---|---|
| `initialDraft` | 各 Draft 型 | 画面オープン時の初期状態スナップショット。差分比較に使用する |
| `showCancelConfirmDialog` | `bool` | true のとき Page が CupertinoAlertDialog を表示する |

> `initialDraft` のデフォルト値は Started ハンドラで設定した Draft と同値。`showCancelConfirmDialog` のデフォルト値は `false`。

---

## 4. Draft Model

変更なし。各 Draft は既存の Equatable 実装を利用して差分比較を行う。

- `MarkDetailDraft` → `==` で比較可能（既存実装）
- `LinkDetailDraft` → `==` で比較可能（既存実装）
- `PaymentDetailDraft` → `==` で比較可能（既存実装）

---

## 5. Domain Model

変更なし。

---

## 6. Projection Model

変更なし。

---

## 7. Adapter

変更なし。

---

## 8. Events

### MarkDetail

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `MarkDetailDismissPressed`（変更） | キャンセルボタン押下 | 差分判定を追加。差分なし → DismissDelegate、差分あり → showCancelConfirmDialog = true |
| `MarkDetailCancelDiscardConfirmed`（追加） | 「破棄する」ボタン押下 | draft を initialDraft に戻して DismissDelegate を emit |
| `MarkDetailCancelDialogDismissed`（追加） | 「編集を続ける」ボタン押下 | showCancelConfirmDialog = false |

### LinkDetail

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `LinkDetailDismissPressed`（変更） | キャンセルボタン押下 | 差分判定を追加。差分なし → DismissDelegate、差分あり → showCancelConfirmDialog = true |
| `LinkDetailCancelDiscardConfirmed`（追加） | 「破棄する」ボタン押下 | draft を initialDraft に戻して DismissDelegate を emit |
| `LinkDetailCancelDialogDismissed`（追加） | 「編集を続ける」ボタン押下 | showCancelConfirmDialog = false |

### PaymentDetail

| Event名 | 発火タイミング | 説明 |
|---|---|---|
| `PaymentDetailDismissPressed`（変更） | キャンセルボタン押下 | 差分判定を追加。差分なし → DismissDelegate、差分あり → showCancelConfirmDialog = true |
| `PaymentDetailCancelDiscardConfirmed`（追加） | 「破棄する」ボタン押下 | draft を initialDraft に戻して DismissDelegate を emit |
| `PaymentDetailCancelDialogDismissed`（追加） | 「編集を続ける」ボタン押下 | showCancelConfirmDialog = false |

---

## 9. Delegate Contract

既存の各 `DismissDelegate` をそのまま使用する。新規 Delegate の追加はなし。

ダイアログ表示は `showCancelConfirmDialog` フラグを State に持たせて Page が描画する方式とする（Delegate 経由ではなく State フラグ方式）。

---

## 10. Data Flow

**差分あり（ダイアログ表示）パス**

1. ユーザーがキャンセルボタンをタップ → `DismissPressed` Event 発火
2. Bloc が `currentDraft != initialDraft` を確認
3. `showCancelConfirmDialog = true` を State に emit
4. Page の BlocBuilder が CupertinoAlertDialog を表示

**「破棄する」選択パス**

5. ユーザーが「破棄する」をタップ → `CancelDiscardConfirmed` Event 発火
6. Bloc が `draft = initialDraft`、`showCancelConfirmDialog = false`、`DismissDelegate` を emit
7. Page の BlocListener が `DismissDelegate` を受け取り `context.pop()`

**「編集を続ける」選択パス**

5. ユーザーが「編集を続ける」をタップ → `CancelDialogDismissed` Event 発火
6. Bloc が `showCancelConfirmDialog = false` を emit
7. ダイアログが閉じる（画面に留まる）

**差分なしパス**

1. ユーザーがキャンセルボタンをタップ → `DismissPressed` Event 発火
2. Bloc が `currentDraft == initialDraft` を確認
3. 直接 `DismissDelegate` を emit
4. Page の BlocListener が `context.pop()`

---

## 11. Bloc Responsibility

各 Bloc（MarkDetailBloc・LinkDetailBloc・PaymentDetailBloc）が以下を追加担当する。

- `Started` ハンドラ: `initialDraft` を Draft と同値で State に設定
- `DismissPressed` ハンドラ: 差分判定ロジックを追加
- `CancelDiscardConfirmed` ハンドラ: Draft リセット + Dismiss
- `CancelDialogDismissed` ハンドラ: showCancelConfirmDialog フラグのリセット

---

## 12. Navigation

変更なし。既存の各 DismissDelegate → `context.pop()` のフローを使用する。

---

## 13. UI 仕様

**CupertinoAlertDialog の内容**

| 項目 | テキスト |
|---|---|
| タイトル | 「変更を破棄しますか？」 |
| メッセージ | 「保存されていない変更は失われます。」 |
| ボタン1（破壊的アクション） | 「破棄する」 |
| ボタン2（キャンセル） | 「編集を続ける」 |

---

## 14. Widget Key 一覧

| キー | 対象画面 | 説明 |
|---|---|---|
| `Key('markDetail_button_cancel')` | MarkDetail | キャンセルボタン |
| `Key('markDetail_button_save')` | MarkDetail | 保存ボタン |
| `Key('markDetail_dialog_cancelConfirm')` | MarkDetail | キャンセル確認ダイアログ |
| `Key('markDetail_button_discardConfirm')` | MarkDetail | ダイアログ内「破棄する」ボタン |
| `Key('markDetail_button_continueEdit')` | MarkDetail | ダイアログ内「編集を続ける」ボタン |
| `Key('linkDetail_button_cancel')` | LinkDetail | キャンセルボタン |
| `Key('linkDetail_button_save')` | LinkDetail | 保存ボタン |
| `Key('linkDetail_dialog_cancelConfirm')` | LinkDetail | キャンセル確認ダイアログ |
| `Key('linkDetail_button_discardConfirm')` | LinkDetail | ダイアログ内「破棄する」ボタン |
| `Key('linkDetail_button_continueEdit')` | LinkDetail | ダイアログ内「編集を続ける」ボタン |
| `Key('paymentDetail_button_cancel')` | PaymentDetail | キャンセルボタン |
| `Key('paymentDetail_button_save')` | PaymentDetail | 保存ボタン |
| `Key('paymentDetail_dialog_cancelConfirm')` | PaymentDetail | キャンセル確認ダイアログ |
| `Key('paymentDetail_button_discardConfirm')` | PaymentDetail | ダイアログ内「破棄する」ボタン |
| `Key('paymentDetail_button_continueEdit')` | PaymentDetail | ダイアログ内「編集を続ける」ボタン |

---

## 15. Test Scenarios

### 前提条件

- アプリ起動済み（`startApp` ヘルパー使用）
- seed データにイベントが1件以上存在し、参加メンバーが1名以上登録されていること
- 各 Detail 画面を開けること

### テストシナリオ一覧

| ID | シナリオ名 | 対象画面 | 優先度 |
|---|---|---|---|
| TC-DCC-001 | MarkDetail: 変更なしでキャンセルするとダイアログが出ない | MarkDetail | High |
| TC-DCC-002 | MarkDetail: 名前を変更してキャンセルするとダイアログが出る | MarkDetail | High |
| TC-DCC-003 | MarkDetail: ダイアログで「破棄する」を選択すると前画面へ戻る | MarkDetail | High |
| TC-DCC-004 | MarkDetail: ダイアログで「編集を続ける」を選択すると画面に留まる | MarkDetail | High |
| TC-DCC-005 | LinkDetail: 変更なしでキャンセルするとダイアログが出ない | LinkDetail | High |
| TC-DCC-006 | LinkDetail: 名前を変更してキャンセルするとダイアログが出る | LinkDetail | High |
| TC-DCC-007 | LinkDetail: ダイアログで「破棄する」を選択すると前画面へ戻る | LinkDetail | High |
| TC-DCC-008 | LinkDetail: ダイアログで「編集を続ける」を選択すると画面に留まる | LinkDetail | High |
| TC-DCC-009 | PaymentDetail: 変更なしでキャンセルするとダイアログが出ない | PaymentDetail | High |
| TC-DCC-010 | PaymentDetail: 金額を入力してキャンセルするとダイアログが出る | PaymentDetail | High |
| TC-DCC-011 | PaymentDetail: ダイアログで「破棄する」を選択すると前画面へ戻る | PaymentDetail | High |
| TC-DCC-012 | PaymentDetail: ダイアログで「編集を続ける」を選択すると画面に留まる | PaymentDetail | High |

---

### TC-DCC-001: MarkDetail — 変更なしでキャンセルするとダイアログが出ない

**前提**
- EventDetail の MichiInfo タブが表示されていること

**手順**
1. マーク追加ボタンをタップして MarkDetail を開く
2. 何も入力せずにキャンセルボタン（`Key('markDetail_button_cancel')`）をタップする

**期待結果**
- CupertinoAlertDialog が表示されない
- MichiInfo タブへ戻る

**実装ノート（ウィジェットキー一覧）**
- `Key('markDetail_button_cancel')` — キャンセルボタン

---

### TC-DCC-002: MarkDetail — 名前を変更してキャンセルするとダイアログが出る

**前提**
- MarkDetail が新規または既存で開かれていること

**手順**
1. MarkDetail を開く
2. 名前フィールド（`Key('markDetail_field_name')`）に任意のテキストを入力する
3. キャンセルボタン（`Key('markDetail_button_cancel')`）をタップする

**期待結果**
- CupertinoAlertDialog（`Key('markDetail_dialog_cancelConfirm')`）が表示される
- タイトル「変更を破棄しますか？」が表示される
- 「破棄する」ボタン（`Key('markDetail_button_discardConfirm')`）が表示される
- 「編集を続ける」ボタン（`Key('markDetail_button_continueEdit')`）が表示される

**実装ノート（ウィジェットキー一覧）**
- `Key('markDetail_field_name')` — MarkDetail 名前入力フィールド
- `Key('markDetail_button_cancel')` — キャンセルボタン
- `Key('markDetail_dialog_cancelConfirm')` — 確認ダイアログ

---

### TC-DCC-003: MarkDetail — ダイアログで「破棄する」を選択すると前画面へ戻る

**前提**
- TC-DCC-002 の状態（ダイアログが表示されている）

**手順**
1. MarkDetail で名前を変更してキャンセルボタンをタップしダイアログを表示する
2. 「破棄する」ボタン（`Key('markDetail_button_discardConfirm')`）をタップする

**期待結果**
- MichiInfo タブへ戻る
- 入力した名前は保存されていない

**実装ノート（ウィジェットキー一覧）**
- `Key('markDetail_button_discardConfirm')` — 「破棄する」ボタン

---

### TC-DCC-004: MarkDetail — ダイアログで「編集を続ける」を選択すると画面に留まる

**前提**
- TC-DCC-002 の状態（ダイアログが表示されている）

**手順**
1. MarkDetail で名前を変更してキャンセルボタンをタップしダイアログを表示する
2. 「編集を続ける」ボタン（`Key('markDetail_button_continueEdit')`）をタップする

**期待結果**
- ダイアログが閉じる
- MarkDetail 画面に留まる
- 入力した名前が入力フィールドに残っている

**実装ノート（ウィジェットキー一覧）**
- `Key('markDetail_button_continueEdit')` — 「編集を続ける」ボタン
- `Key('markDetail_field_name')` — 名前入力フィールド

---

### TC-DCC-005: LinkDetail — 変更なしでキャンセルするとダイアログが出ない

**前提**
- EventDetail の MichiInfo タブが表示されていること

**手順**
1. リンク追加ボタンをタップして LinkDetail を開く
2. 何も入力せずにキャンセルボタン（`Key('linkDetail_button_cancel')`）をタップする

**期待結果**
- CupertinoAlertDialog が表示されない
- MichiInfo タブへ戻る

**実装ノート（ウィジェットキー一覧）**
- `Key('linkDetail_button_cancel')` — キャンセルボタン

---

### TC-DCC-006: LinkDetail — 名前を変更してキャンセルするとダイアログが出る

**手順**
1. LinkDetail を開く
2. 名前フィールド（`Key('linkDetail_field_name')`）に任意のテキストを入力する
3. キャンセルボタン（`Key('linkDetail_button_cancel')`）をタップする

**期待結果**
- CupertinoAlertDialog（`Key('linkDetail_dialog_cancelConfirm')`）が表示される

**実装ノート（ウィジェットキー一覧）**
- `Key('linkDetail_field_name')` — LinkDetail 名前入力フィールド
- `Key('linkDetail_button_cancel')` — キャンセルボタン
- `Key('linkDetail_dialog_cancelConfirm')` — 確認ダイアログ

---

### TC-DCC-007: LinkDetail — ダイアログで「破棄する」を選択すると前画面へ戻る

**手順**
1. LinkDetail で名前を変更してキャンセルボタンをタップしダイアログを表示する
2. 「破棄する」ボタン（`Key('linkDetail_button_discardConfirm')`）をタップする

**期待結果**
- MichiInfo タブへ戻る
- 入力した名前は保存されていない

**実装ノート（ウィジェットキー一覧）**
- `Key('linkDetail_button_discardConfirm')` — 「破棄する」ボタン

---

### TC-DCC-008: LinkDetail — ダイアログで「編集を続ける」を選択すると画面に留まる

**手順**
1. LinkDetail で名前を変更してキャンセルボタンをタップしダイアログを表示する
2. 「編集を続ける」ボタン（`Key('linkDetail_button_continueEdit')`）をタップする

**期待結果**
- ダイアログが閉じる
- LinkDetail 画面に留まる
- 入力した名前が入力フィールドに残っている

**実装ノート（ウィジェットキー一覧）**
- `Key('linkDetail_button_continueEdit')` — 「編集を続ける」ボタン

---

### TC-DCC-009: PaymentDetail — 変更なしでキャンセルするとダイアログが出ない

**前提**
- EventDetail の PaymentInfo タブが表示されていること

**手順**
1. 支払い追加ボタンをタップして PaymentDetail を開く
2. 何も入力せずにキャンセルボタン（`Key('paymentDetail_button_cancel')`）をタップする

**期待結果**
- CupertinoAlertDialog が表示されない
- PaymentInfo タブへ戻る

**実装ノート（ウィジェットキー一覧）**
- `Key('paymentDetail_button_cancel')` — キャンセルボタン

---

### TC-DCC-010: PaymentDetail — 金額を入力してキャンセルするとダイアログが出る

**手順**
1. PaymentDetail を開く
2. 金額フィールド（`Key('paymentDetail_field_amount')`）に任意の金額を入力する
3. キャンセルボタン（`Key('paymentDetail_button_cancel')`）をタップする

**期待結果**
- CupertinoAlertDialog（`Key('paymentDetail_dialog_cancelConfirm')`）が表示される

**実装ノート（ウィジェットキー一覧）**
- `Key('paymentDetail_field_amount')` — 金額入力フィールド
- `Key('paymentDetail_button_cancel')` — キャンセルボタン
- `Key('paymentDetail_dialog_cancelConfirm')` — 確認ダイアログ

---

### TC-DCC-011: PaymentDetail — ダイアログで「破棄する」を選択すると前画面へ戻る

**手順**
1. PaymentDetail で金額を入力してキャンセルボタンをタップしダイアログを表示する
2. 「破棄する」ボタン（`Key('paymentDetail_button_discardConfirm')`）をタップする

**期待結果**
- PaymentInfo タブへ戻る
- 入力した金額は保存されていない

**実装ノート（ウィジェットキー一覧）**
- `Key('paymentDetail_button_discardConfirm')` — 「破棄する」ボタン

---

### TC-DCC-012: PaymentDetail — ダイアログで「編集を続ける」を選択すると画面に留まる

**手順**
1. PaymentDetail で金額を入力してキャンセルボタンをタップしダイアログを表示する
2. 「編集を続ける」ボタン（`Key('paymentDetail_button_continueEdit')`）をタップする

**期待結果**
- ダイアログが閉じる
- PaymentDetail 画面に留まる
- 入力した金額が入力フィールドに残っている

**実装ノート（ウィジェットキー一覧）**
- `Key('paymentDetail_button_continueEdit')` — 「編集を続ける」ボタン
- `Key('paymentDetail_field_amount')` — 金額入力フィールド

---

## 16. 備考

- `initialDraft` は `Started` ハンドラで Domain から生成した Draft と同値で保持する
- 新規作成モード（Draft が空の初期状態）の場合も、入力後にキャンセルすればダイアログが表示される（REQ-DCC-005 対応）。新規作成時の `initialDraft` は空の初期 Draft（各フィールドがデフォルト値）となるため、何か入力された時点で差分が生じる
- UI-12 との組み合わせ: PaymentDetail（または MarkDetail・LinkDetail）でダイアログの「破棄する」を選択 → Dismiss → EventDetail に戻る → EventDetail でバックボタンを押す → UI-12 の未保存判定が走る（MarkDetail・LinkDetail・PaymentDetail の保存完了が一度もなければ削除される）
- `showCancelConfirmDialog = true` の状態から BlocBuilder を使って Page 内でダイアログを表示する実装とする。Dialog 表示後に別 Event（`CancelDiscardConfirmed` / `CancelDialogDismissed`）を Bloc に送る形で処理する
