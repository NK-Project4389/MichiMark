# Feature Spec: FS-detail_screen_ui_improvement

- **Spec ID**: FS-detail_screen_ui_improvement
- **対応要件**: REQ-detail_screen_ui_improvement
- **作成日**: 2026-04-12
- **ステータス**: 確定
- **対象Feature**: mark_detail / link_detail / payment_detail

---

## 1. Purpose

MarkDetail・LinkDetail・PaymentDetail の3画面について、以下のUI改善を行う。

1. AppBar の戻るボタン（leading）を廃止する
2. AppBar タイトルを画面プレフィックス付きフォーマットに統一する
3. 保存ボタンを FloatingActionButton からフォーム最下部のインラインボタンに移動し、キャンセルボタンを横並びで追加する

---

## 2. 共通変更パターン

3画面はすべて同一の変更パターンを適用する。各画面固有の差異は §3〜§5 に記載する。

### 2.1 戻るボタン廃止

- AppBar の `leading` プロパティを削除する
- AppBar に `automaticallyImplyLeading: false` を設定する
- 既存の `leading` に割り当てられていた dismiss/cancel イベントは、フォーム最下部のキャンセルボタンに移管する

### 2.2 ヘッダタイトル変更方針

| 画面 | Draft上の名称フィールド | タイトル（名称あり） | タイトル（名称なし・空） |
|---|---|---|---|
| MarkDetail | `MarkDetailDraft.markLinkName` | `地点詳細：(markLinkName)` | `地点詳細` |
| LinkDetail | `LinkDetailDraft.markLinkName` | `区間詳細：(markLinkName)` | `区間詳細` |
| PaymentDetail | （名称フィールドなし） | — | `支払詳細` |

> **設計注記（PaymentDetail）**: `PaymentDetailDraft` には名称を表すフィールドが存在しない。要件書の「支払詳細：(名称)」における名称は既存フィールドでは代替できないため、PaymentDetail のタイトルは `支払詳細` 固定とする。入力フィールドの追加は要件対象外（REQ §4）。

- タイトルはBlocのState（`MarkDetailLoaded.draft` / `LinkDetailLoaded.draft` / `PaymentDetailLoaded.draft`）から取得する
- Widget は Bloc にタイトル生成ロジックを持たせず、Stateから取得した文字列をそのまま表示する

### 2.3 キャンセル・保存ボタン配置変更

**変更前**
- キャンセル: AppBar leading（戻るボタンで代替）
- 保存: FloatingActionButton（右下）

**変更後**
- AppBar の FloatingActionButton を削除する
- フォームの最下部（Listviewの末尾）にボタン行を追加する
- ボタン行レイアウト:
  - 横並び（Row）・中央寄せ（MainAxisAlignment.center）
  - 左: キャンセルボタン
  - 右: 保存ボタン
  - 2ボタン間に適切な水平余白を設ける

**キャンセルボタンの挙動**
- タップ時: 既存の dismiss/cancel イベントをBlocに送出する（変更なし）
- BlocListenerが `DismissDelegate` を受け取り `context.pop()` で画面を閉じる

**保存ボタンの挙動**
- タップ時: 既存の save イベントをBlocに送出する（変更なし）
- `isSaving == true` の間は非活性（disabled）にする
- `isSaving == true` の間はボタン内にローディングインジケーターを表示する

---

## 3. MarkDetail 固有仕様

### 3.1 現状（変更前）

| 項目 | 現状 |
|---|---|
| AppBar leading | `IconButton(Icons.chevron_left)` → `MarkDetailDismissPressed` |
| AppBar タイトル | `markLinkName`（空時: `地点詳細`） |
| 保存UI | `FloatingActionButton.extended`（右下） |

### 3.2 変更後

| 項目 | 変更後 |
|---|---|
| AppBar leading | なし（`automaticallyImplyLeading: false`） |
| AppBar タイトル | 名称あり: `地点詳細：(markLinkName)` / 空: `地点詳細` |
| 保存UI | フォーム最下部のインラインボタン行 |
| キャンセルボタン | `MarkDetailDismissPressed` を送出 |
| 保存ボタン | `MarkDetailSaveTapped` を送出 |

### 3.3 BlocEvent（既存イベントを流用）

追加・変更なし。以下の既存イベントをボタン行に接続する。

- キャンセル → `MarkDetailDismissPressed`（既存）
- 保存 → `MarkDetailSaveTapped`（既存）

---

## 4. LinkDetail 固有仕様

### 4.1 現状（変更前）

| 項目 | 現状 |
|---|---|
| AppBar leading | `IconButton(Icons.chevron_left)` → `LinkDetailDismissPressed` |
| AppBar タイトル | `markLinkName`（空時: `区間詳細`） |
| 保存UI | `FloatingActionButton.extended`（右下） |

### 4.2 変更後

| 項目 | 変更後 |
|---|---|
| AppBar leading | なし（`automaticallyImplyLeading: false`） |
| AppBar タイトル | 名称あり: `区間詳細：(markLinkName)` / 空: `区間詳細` |
| 保存UI | フォーム最下部のインラインボタン行 |
| キャンセルボタン | `LinkDetailDismissPressed` を送出 |
| 保存ボタン | `LinkDetailSaveTapped` を送出 |

### 4.3 BlocEvent（既存イベントを流用）

追加・変更なし。以下の既存イベントをボタン行に接続する。

- キャンセル → `LinkDetailDismissPressed`（既存）
- 保存 → `LinkDetailSaveTapped`（既存）

---

## 5. PaymentDetail 固有仕様

### 5.1 現状（変更前）

| 項目 | 現状 |
|---|---|
| AppBar leading | `IconButton(Icons.close)` → `PaymentDetailCancelTapped` |
| AppBar タイトル | `支払詳細`（固定） |
| 保存UI | `FloatingActionButton.extended`（右下） |

### 5.2 変更後

| 項目 | 変更後 |
|---|---|
| AppBar leading | なし（`automaticallyImplyLeading: false`） |
| AppBar タイトル | `支払詳細`（固定・名称フィールドなしのため変更なし） |
| 保存UI | フォーム最下部のインラインボタン行 |
| キャンセルボタン | `PaymentDetailCancelTapped` を送出 |
| 保存ボタン | `PaymentDetailSaveTapped` を送出 |

### 5.3 BlocEvent（既存イベントを流用）

追加・変更なし。以下の既存イベントをボタン行に接続する。

- キャンセル → `PaymentDetailCancelTapped`（既存）
- 保存 → `PaymentDetailSaveTapped`（既存）

---

## 6. State から参照するフィールド一覧（タイトル生成）

| 画面 | State | タイトル生成に使用するフィールド |
|---|---|---|
| MarkDetail | `MarkDetailLoaded` | `draft.markLinkName` |
| LinkDetail | `LinkDetailLoaded` | `draft.markLinkName` |
| PaymentDetail | `PaymentDetailLoaded` | なし（固定文字列） |

---

## 7. Data Flow

### キャンセル操作

1. ユーザーがキャンセルボタンをタップする
2. Widget が BlocにDismissイベント（`DismissPressed` / `CancelTapped`）を送出する
3. Bloc が `DismissDelegate` をStateに乗せる
4. BlocListenerが `DismissDelegate` を受け取り `context.pop()` で画面を閉じる

### 保存操作

1. ユーザーが保存ボタンをタップする
2. Widget が BlocにSaveイベント（`SaveTapped`）を送出する
3. Bloc が `isSaving: true` を emit する（ボタンが非活性になる）
4. Bloc が保存処理を実行し、`SavedDelegate` または `SaveErrorDelegate` をStateに乗せる
5. BlocListenerが `SavedDelegate` を受け取り `context.pop()` で画面を閉じる
6. `SaveErrorDelegate` の場合はSnackBarでエラーを表示する

---

## 8. Router変更方針

変更なし。3画面ともルート定義・遷移パスの変更は不要。

---

## 9. Test Scenarios

### 前提条件

- iOSシミュレーターが起動済みであること
- テスト用イベントデータが存在すること（MarkLink・Paymentを含む）
- 各詳細画面を開ける状態であること

### テストシナリオ一覧

| ID | シナリオ名 | 対象画面 | 優先度 |
|---|---|---|---|
| TC-DSI-001 | MarkDetail：戻るボタンが表示されないこと | MarkDetail | High |
| TC-DSI-002 | LinkDetail：戻るボタンが表示されないこと | LinkDetail | High |
| TC-DSI-003 | PaymentDetail：戻るボタンが表示されないこと | PaymentDetail | High |
| TC-DSI-004 | MarkDetail：ヘッダタイトルが「地点詳細：(名称)」形式で表示されること | MarkDetail | High |
| TC-DSI-005 | LinkDetail：ヘッダタイトルが「区間詳細：(名称)」形式で表示されること | LinkDetail | High |
| TC-DSI-006 | PaymentDetail：ヘッダタイトルが「支払詳細」で表示されること | PaymentDetail | High |
| TC-DSI-007 | MarkDetail：キャンセル・保存ボタンがフォーム最下部に横並び表示されること | MarkDetail | High |
| TC-DSI-008 | LinkDetail：キャンセル・保存ボタンがフォーム最下部に横並び表示されること | LinkDetail | High |
| TC-DSI-009 | PaymentDetail：キャンセル・保存ボタンがフォーム最下部に横並び表示されること | PaymentDetail | High |
| TC-DSI-010 | MarkDetail：キャンセルボタンタップで画面が閉じること | MarkDetail | High |
| TC-DSI-011 | LinkDetail：キャンセルボタンタップで画面が閉じること | LinkDetail | High |
| TC-DSI-012 | PaymentDetail：キャンセルボタンタップで画面が閉じること | PaymentDetail | High |
| TC-DSI-013 | MarkDetail：保存ボタンタップで保存されて画面が閉じること | MarkDetail | High |
| TC-DSI-014 | LinkDetail：保存ボタンタップで保存されて画面が閉じること | LinkDetail | High |
| TC-DSI-015 | PaymentDetail：保存ボタンタップで保存されて画面が閉じること | PaymentDetail | High |

---

### TC-DSI-001: MarkDetail — 戻るボタンが表示されないこと

**前提:**
- イベントにMarkLinkが1件以上存在する

**手順:**
1. MichiInfo画面でMarkをタップしてMarkDetail画面を開く

**期待結果:**
- AppBar左端にボタン（`<` アイコン等）が表示されない

**実装ノート（ウィジェットキー）:**
- `Key('markDetail_appBar_backButton')` が存在しないこと

---

### TC-DSI-002: LinkDetail — 戻るボタンが表示されないこと

**前提:**
- イベントにLinkが1件以上存在する

**手順:**
1. MichiInfo画面でLinkをタップしてLinkDetail画面を開く

**期待結果:**
- AppBar左端にボタンが表示されない

**実装ノート（ウィジェットキー）:**
- `Key('linkDetail_appBar_backButton')` が存在しないこと

---

### TC-DSI-003: PaymentDetail — 戻るボタンが表示されないこと

**前提:**
- イベントにPaymentが1件以上存在する

**手順:**
1. PaymentInfo画面でPaymentをタップしてPaymentDetail画面を開く

**期待結果:**
- AppBar左端にボタンが表示されない

**実装ノート（ウィジェットキー）:**
- `Key('paymentDetail_appBar_backButton')` が存在しないこと

---

### TC-DSI-004: MarkDetail — ヘッダタイトルが「地点詳細：(名称)」形式であること

**前提:**
- 名称が「〇〇SA」に設定されたMarkLinkが存在する

**手順:**
1. 当該MarkLinkの MarkDetail 画面を開く

**期待結果:**
- AppBar タイトルに `地点詳細：〇〇SA` が表示される

**実装ノート（ウィジェットキー）:**
- `Key('markDetail_appBar_title')` のテキストが `地点詳細：〇〇SA` であること

---

### TC-DSI-005: LinkDetail — ヘッダタイトルが「区間詳細：(名称)」形式であること

**前提:**
- 名称が「〇〇〜△△」に設定されたLinkが存在する

**手順:**
1. 当該Link の LinkDetail 画面を開く

**期待結果:**
- AppBar タイトルに `区間詳細：〇〇〜△△` が表示される

**実装ノート（ウィジェットキー）:**
- `Key('linkDetail_appBar_title')` のテキストが `区間詳細：〇〇〜△△` であること

---

### TC-DSI-006: PaymentDetail — ヘッダタイトルが「支払詳細」であること

**手順:**
1. PaymentDetail 画面を開く

**期待結果:**
- AppBar タイトルに `支払詳細` が表示される

**実装ノート（ウィジェットキー）:**
- `Key('paymentDetail_appBar_title')` のテキストが `支払詳細` であること

---

### TC-DSI-007: MarkDetail — キャンセル・保存ボタンがフォーム最下部に表示されること

**手順:**
1. MarkDetail 画面を開く
2. フォームを最下部までスクロールする

**期待結果:**
- `Key('markDetail_button_cancel')` が表示される
- `Key('markDetail_button_save')` が表示される
- キャンセルボタンが左・保存ボタンが右に横並びで表示される

---

### TC-DSI-008: LinkDetail — キャンセル・保存ボタンがフォーム最下部に表示されること

**手順:**
1. LinkDetail 画面を開く
2. フォームを最下部までスクロールする

**期待結果:**
- `Key('linkDetail_button_cancel')` が表示される
- `Key('linkDetail_button_save')` が表示される
- キャンセルボタンが左・保存ボタンが右に横並びで表示される

---

### TC-DSI-009: PaymentDetail — キャンセル・保存ボタンがフォーム最下部に表示されること

**手順:**
1. PaymentDetail 画面を開く
2. フォームを最下部までスクロールする

**期待結果:**
- `Key('paymentDetail_button_cancel')` が表示される
- `Key('paymentDetail_button_save')` が表示される
- キャンセルボタンが左・保存ボタンが右に横並びで表示される

---

### TC-DSI-010: MarkDetail — キャンセルタップで画面が閉じること

**前提:**
- MarkDetail 画面が開いている

**手順:**
1. フォームを最下部までスクロールする
2. `Key('markDetail_button_cancel')` をタップする

**期待結果:**
- MarkDetail 画面が閉じ、前の画面（MichiInfo）に戻る
- 変更（編集中の内容）は保存されていない

---

### TC-DSI-011: LinkDetail — キャンセルタップで画面が閉じること

**前提:**
- LinkDetail 画面が開いている

**手順:**
1. フォームを最下部までスクロールする
2. `Key('linkDetail_button_cancel')` をタップする

**期待結果:**
- LinkDetail 画面が閉じ、前の画面に戻る
- 変更は保存されていない

---

### TC-DSI-012: PaymentDetail — キャンセルタップで画面が閉じること

**前提:**
- PaymentDetail 画面が開いている

**手順:**
1. フォームを最下部までスクロールする
2. `Key('paymentDetail_button_cancel')` をタップする

**期待結果:**
- PaymentDetail 画面が閉じ、前の画面に戻る
- 変更は保存されていない

---

### TC-DSI-013: MarkDetail — 保存タップで保存されて画面が閉じること

**前提:**
- MarkDetail 画面が開いている

**手順:**
1. フォームを最下部までスクロールする
2. `Key('markDetail_button_save')` をタップする
3. 保存完了を待つ

**期待結果:**
- MarkDetail 画面が閉じ、前の画面（MichiInfo）に戻る
- 保存した内容がMichiInfo画面のリストに反映されている

---

### TC-DSI-014: LinkDetail — 保存タップで保存されて画面が閉じること

**前提:**
- LinkDetail 画面が開いている

**手順:**
1. フォームを最下部までスクロールする
2. `Key('linkDetail_button_save')` をタップする
3. 保存完了を待つ

**期待結果:**
- LinkDetail 画面が閉じ、前の画面に戻る
- 保存した内容が一覧に反映されている

---

### TC-DSI-015: PaymentDetail — 保存タップで保存されて画面が閉じること

**前提:**
- PaymentDetail 画面が開いている

**手順:**
1. フォームを最下部までスクロールする
2. `Key('paymentDetail_button_save')` をタップする
3. 保存完了を待つ

**期待結果:**
- PaymentDetail 画面が閉じ、前の画面（PaymentInfo）に戻る
- 保存した内容がPaymentInfo画面のリストに反映されている

---

## 10. ウィジェットキー一覧

| Key | 画面 | 種別 | 説明 |
|---|---|---|---|
| `Key('markDetail_appBar_title')` | MarkDetail | テキスト | AppBar タイトル |
| `Key('markDetail_appBar_backButton')` | MarkDetail | ボタン | 存在しないことを確認するためのキー（実装しない） |
| `Key('markDetail_button_cancel')` | MarkDetail | ボタン | キャンセルボタン |
| `Key('markDetail_button_save')` | MarkDetail | ボタン | 保存ボタン |
| `Key('linkDetail_appBar_title')` | LinkDetail | テキスト | AppBar タイトル |
| `Key('linkDetail_appBar_backButton')` | LinkDetail | ボタン | 存在しないことを確認するためのキー（実装しない） |
| `Key('linkDetail_button_cancel')` | LinkDetail | ボタン | キャンセルボタン |
| `Key('linkDetail_button_save')` | LinkDetail | ボタン | 保存ボタン |
| `Key('paymentDetail_appBar_title')` | PaymentDetail | テキスト | AppBar タイトル |
| `Key('paymentDetail_appBar_backButton')` | PaymentDetail | ボタン | 存在しないことを確認するためのキー（実装しない） |
| `Key('paymentDetail_button_cancel')` | PaymentDetail | ボタン | キャンセルボタン |
| `Key('paymentDetail_button_save')` | PaymentDetail | ボタン | 保存ボタン |

---

## 11. 実装スコープ（変更対象ファイル）

以下のファイルのみ変更する。BlocEvent・State・Draft・Adapter・Repositoryの変更は不要。

| ファイル | 変更内容 |
|---|---|
| `flutter/lib/features/mark_detail/view/mark_detail_page.dart` | AppBar leading削除・タイトル変更・FAB削除・フォーム末尾にボタン行追加 |
| `flutter/lib/features/link_detail/view/link_detail_page.dart` | 同上 |
| `flutter/lib/features/payment_detail/view/payment_detail_page.dart` | 同上 |

---

# End of Spec
