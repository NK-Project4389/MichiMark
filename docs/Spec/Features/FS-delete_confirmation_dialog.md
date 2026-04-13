# Feature Spec: 削除確認ダイアログ

- **Spec ID**: FS-delete_confirmation_dialog
- **要件ID**: REQ-delete_confirmation_dialog
- **作成日**: 2026-04-13
- **担当**: architect
- **ステータス**: 確定
- **種別**: UI改善（UI-7）

---

## 1. Feature Overview

### Feature Name

DeleteConfirmationDialog

### Purpose

MichiInfo（Markカード・Linkカード）および PaymentInfo（伝票カード）の削除ボタン押下時に、
確認ダイアログを表示して誤操作によるデータ消失を防ぐ。

### Scope

含むもの
- MichiInfo の Mark / Link カード削除ボタン押下時の確認ダイアログ表示
- PaymentInfo の伝票カード削除ボタン押下時の確認ダイアログ表示
- 「削除」タップ時の既存削除イベント dispatch
- 「キャンセル」タップ時のダイアログ閉鎖のみ（削除なし）

含まないもの
- Bloc / Draft / Domain の変更
- 新規 BlocEvent の追加
- 削除後の処理変更
- 削除 Undo 機能
- 画面遷移・アニメーション変更

---

## 2. 設計方針

### ダイアログ表示レイヤー

ダイアログ表示は **View 層（Widget）** で行う。Bloc は関与しない。

```
ゴミ箱アイコン onTap
  ↓
showCupertinoDialog（View層）
  ↓
「削除」ボタンタップ
  ↓
既存の削除 BlocEvent を dispatch
```

**根拠**: 削除確認ダイアログはビジネスロジックではなくUIの保護機構であり、
設計憲章の「Widget は UI 表示のみを担当」に準じた変更のみで実現できる。
Bloc・Domain・Draft のレイヤーに変更は不要。

### 使用コンポーネント

`showCupertinoDialog` を使用する（iOS ネイティブスタイル統一のため）。
- タイトル: `「削除しますか？」`
- メッセージ: `「この操作は取り消せません。」`
- 「削除」ボタン: `CupertinoDialogAction`（isDestructiveAction: true）
- 「キャンセル」ボタン: `CupertinoDialogAction`

### async gap と BuildContext の扱い

`showCupertinoDialog` は非同期処理を伴う。`await` 後に `context` を使用する場合は
`mounted` チェックが必須（設計憲章 14.3 に準拠）。

---

## 3. 影響を受けるファイル

| ファイル | 変更内容 |
|---|---|
| `flutter/lib/features/michi_info/view/michi_info_view.dart` | ゴミ箱アイコンの `onTap` に `showCupertinoDialog` を挿入 |
| `flutter/lib/features/payment_info/view/payment_info_view.dart` | ゴミ箱アイコンの `onTap` に `showCupertinoDialog` を挿入 |

変更なし:
- `michi_info_bloc.dart` / `michi_info_event.dart` / `michi_info_state.dart`
- `payment_info_bloc.dart` / `payment_info_event.dart` / `payment_info_state.dart`
- Domain / Draft / Repository 各レイヤー

---

## 4. 既存削除イベント（再利用）

新規イベントは作成しない。以下の既存イベントをそのまま使用する。

| Feature | 既存イベント | 引数 |
|---|---|---|
| MichiInfo | `MichiInfoCardDeleteRequested` | `markLinkId: String` |
| PaymentInfo | `PaymentInfoPaymentDeleteRequested` | `paymentId: String` |

---

## 5. Data Flow

- ゴミ箱アイコンをタップする
- View 層で `showCupertinoDialog` を呼び出す
- ダイアログが表示される
- 「キャンセル」タップ → `Navigator.of(context).pop()` → ダイアログを閉じる（削除しない）
- 「削除」タップ → `Navigator.of(context).pop()` → `context.mounted` チェック → 既存の削除 BlocEvent を dispatch

---

## 6. ダイアログ仕様

| 項目 | 内容 |
|---|---|
| ダイアログ種別 | `CupertinoAlertDialog` |
| タイトル | 「削除しますか？」 |
| メッセージ | 「この操作は取り消せません。」 |
| 「削除」ボタン | 赤色（`isDestructiveAction: true`） |
| 「キャンセル」ボタン | 標準スタイル |
| ボタン配置 | キャンセル（左）、削除（右） |

---

## 7. Widget Key 定義

| キー | 対象要素 | 備考 |
|---|---|---|
| `Key('michiInfo_button_delete_${item.id}')` | MichiInfo ゴミ箱ボタン（既存） | 変更なし |
| `Key('paymentInfo_button_delete_${item.id}')` | PaymentInfo ゴミ箱ボタン（既存） | 変更なし |
| `Key('deleteConfirmDialog_dialog_confirm')` | 確認ダイアログ本体 | 新規追加 |
| `Key('deleteConfirmDialog_button_delete')` | ダイアログの「削除」ボタン | 新規追加 |
| `Key('deleteConfirmDialog_button_cancel')` | ダイアログの「キャンセル」ボタン | 新規追加 |

---

## 8. Test Scenarios

### 前提条件

- iOSシミュレーター（UDID: `DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6`）が起動済みであること
- MichiInfo テスト: イベントに Mark カードが 1 件以上登録済みであること
- MichiInfo テスト: イベントに Link カードが 1 件以上登録済みであること
- PaymentInfo テスト: イベントに伝票（支払情報）が 1 件以上登録済みであること

### テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-DCD-001 | MichiInfo Mark カードのゴミ箱アイコンをタップすると確認ダイアログが表示される | High |
| TC-DCD-002 | 確認ダイアログで「キャンセル」をタップするとダイアログが閉じ、カードが削除されない | High |
| TC-DCD-003 | 確認ダイアログで「削除」をタップするとダイアログが閉じ、カードが削除される | High |
| TC-DCD-004 | MichiInfo Link カードのゴミ箱アイコンをタップすると確認ダイアログが表示される | High |
| TC-DCD-005 | PaymentInfo 伝票カードのゴミ箱アイコンをタップすると確認ダイアログが表示される | High |
| TC-DCD-006 | PaymentInfo の確認ダイアログで「削除」をタップすると伝票が削除される | High |

---

### TC-DCD-001: MichiInfo Mark カードのゴミ箱アイコンをタップすると確認ダイアログが表示される

**前提:**
- MichiInfo 画面（ミチタブ）が表示されていること
- Mark カードが 1 件以上存在すること

**手順:**
1. 一覧に表示された Mark カード（`michiInfo_button_delete_${id}`）のゴミ箱アイコンをタップする

**期待結果:**
- `Key('deleteConfirmDialog_dialog_confirm')` を持つ確認ダイアログが表示される
- ダイアログにタイトル「削除しますか？」が表示される
- ダイアログにメッセージ「この操作は取り消せません。」が表示される
- 「削除」ボタンと「キャンセル」ボタンが表示される
- Mark カードはまだ一覧に残っている

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_button_delete_${id}')` — ゴミ箱ボタン
- `Key('deleteConfirmDialog_dialog_confirm')` — ダイアログ本体
- `Key('deleteConfirmDialog_button_delete')` — 削除ボタン
- `Key('deleteConfirmDialog_button_cancel')` — キャンセルボタン

---

### TC-DCD-002: 確認ダイアログで「キャンセル」をタップするとダイアログが閉じ、カードが削除されない

**前提:**
- MichiInfo 画面（ミチタブ）が表示されていること
- Mark カードが 1 件以上存在すること

**手順:**
1. Mark カードのゴミ箱アイコン（`michiInfo_button_delete_${id}`）をタップする
2. 確認ダイアログが表示されたことを確認する
3. `Key('deleteConfirmDialog_button_cancel')` をタップする

**期待結果:**
- ダイアログが閉じる（`deleteConfirmDialog_dialog_confirm` が非表示になる）
- Mark カードが一覧に残っている（削除されない）

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_button_delete_${id}')` — ゴミ箱ボタン
- `Key('deleteConfirmDialog_dialog_confirm')` — ダイアログ本体
- `Key('deleteConfirmDialog_button_cancel')` — キャンセルボタン

---

### TC-DCD-003: 確認ダイアログで「削除」をタップするとダイアログが閉じ、カードが削除される

**前提:**
- MichiInfo 画面（ミチタブ）が表示されていること
- Mark カードが 1 件以上存在し、削除対象カードの `id` が既知であること

**手順:**
1. 削除対象の Mark カードのゴミ箱アイコン（`michiInfo_button_delete_${id}`）をタップする
2. 確認ダイアログが表示されたことを確認する
3. `Key('deleteConfirmDialog_button_delete')` をタップする

**期待結果:**
- ダイアログが閉じる（`deleteConfirmDialog_dialog_confirm` が非表示になる）
- 削除対象の Mark カード（`michiInfo_button_delete_${id}`）が一覧から消える

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_button_delete_${id}')` — ゴミ箱ボタン
- `Key('deleteConfirmDialog_dialog_confirm')` — ダイアログ本体
- `Key('deleteConfirmDialog_button_delete')` — 削除ボタン

---

### TC-DCD-004: MichiInfo Link カードのゴミ箱アイコンをタップすると確認ダイアログが表示される

**前提:**
- MichiInfo 画面（ミチタブ）が表示されていること
- Link カードが 1 件以上存在すること

**手順:**
1. 一覧に表示された Link カード（`michiInfo_button_delete_${id}`）のゴミ箱アイコンをタップする

**期待結果:**
- `Key('deleteConfirmDialog_dialog_confirm')` を持つ確認ダイアログが表示される
- 「削除しますか？」「この操作は取り消せません。」のテキストが表示される
- Link カードはまだ一覧に残っている

**実装ノート（ウィジェットキー）:**
- `Key('michiInfo_button_delete_${id}')` — ゴミ箱ボタン（Link カード）
- `Key('deleteConfirmDialog_dialog_confirm')` — ダイアログ本体

---

### TC-DCD-005: PaymentInfo 伝票カードのゴミ箱アイコンをタップすると確認ダイアログが表示される

**前提:**
- PaymentInfo 画面（支払タブ）が表示されていること
- 伝票が 1 件以上存在すること

**手順:**
1. 伝票カードのゴミ箱アイコン（`paymentInfo_button_delete_${id}`）をタップする

**期待結果:**
- `Key('deleteConfirmDialog_dialog_confirm')` を持つ確認ダイアログが表示される
- 「削除しますか？」「この操作は取り消せません。」のテキストが表示される
- 伝票カードはまだ一覧に残っている

**実装ノート（ウィジェットキー）:**
- `Key('paymentInfo_button_delete_${id}')` — ゴミ箱ボタン（既存キー）
- `Key('deleteConfirmDialog_dialog_confirm')` — ダイアログ本体
- `Key('deleteConfirmDialog_button_delete')` — 削除ボタン
- `Key('deleteConfirmDialog_button_cancel')` — キャンセルボタン

---

### TC-DCD-006: PaymentInfo の確認ダイアログで「削除」をタップすると伝票が削除される

**前提:**
- PaymentInfo 画面（支払タブ）が表示されていること
- 伝票が 1 件以上存在し、削除対象伝票の `id` が既知であること

**手順:**
1. 削除対象の伝票カードのゴミ箱アイコン（`paymentInfo_button_delete_${id}`）をタップする
2. 確認ダイアログが表示されたことを確認する
3. `Key('deleteConfirmDialog_button_delete')` をタップする

**期待結果:**
- ダイアログが閉じる（`deleteConfirmDialog_dialog_confirm` が非表示になる）
- 削除対象の伝票カード（`paymentInfo_button_delete_${id}`）が一覧から消える

**実装ノート（ウィジェットキー）:**
- `Key('paymentInfo_button_delete_${id}')` — ゴミ箱ボタン
- `Key('deleteConfirmDialog_dialog_confirm')` — ダイアログ本体
- `Key('deleteConfirmDialog_button_delete')` — 削除ボタン

---

## End of Feature Spec
