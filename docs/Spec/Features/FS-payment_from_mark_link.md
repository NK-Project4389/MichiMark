# Feature Specification: MarkDetail / LinkDetail からの支払い登録

**ID:** FS-payment_from_mark_link
**要件書:** docs/Requirements/REQ-payment_from_mark_link.md
**バージョン:** 1.0

---

## 1. Feature Overview

### Purpose

MarkDetail・LinkDetail 画面に支払セクションを追加し、その場から PaymentDetail を登録できるようにする。
登録した支払いは PaymentInfo タブにも反映される。
MarkDetail・LinkDetail が削除された場合、紐づく支払いはカスケード削除される。

### Parent Feature

EventDetailFeature

---

## 2. Domain 変更

### 2.1 PaymentDomain に markLinkID フィールドを追加

```dart
class PaymentDomain extends Equatable {
  // 既存フィールド...

  /// 紐づく MarkLink の ID。null = PaymentInfo タブから直接登録
  final String? markLinkID;
}
```

- `markLinkID` は nullable。NULL = 直接登録（PaymentInfo タブ経由）
- drift テーブル `PaymentTable` に `TextColumn markLinkID` を追加（nullable）
- マイグレーション: `schemaVersion` を +1 し `addColumn` で追加

### 2.2 PaymentDetailDraft に markLinkID フィールドを追加

```dart
class PaymentDetailDraft extends Equatable {
  // 既存フィールド...

  /// 紐づく MarkLink の ID（null = 直接登録）
  final String? markLinkID;
}
```

### 2.3 PaymentDetailArgs に markLinkID フィールドを追加

```dart
class PaymentDetailArgs {
  final String eventId;
  final String? paymentId;

  /// MarkDetail/LinkDetail から開く場合に指定。null = PaymentInfo からの直接登録
  final String? markLinkID;
}
```

---

## 3. MarkDetailFeature 変更

### 3.1 Delegate 追加

```dart
sealed class MarkDetailDelegate

// 既存
MarkDetailDismissDelegate
MarkDetailOpenActionsSelectionDelegate
MarkDetailSavedDelegate
MarkDetailSaveErrorDelegate

// 追加
MarkDetailOpenPaymentNewDelegate(String markLinkId)
  - 支払セクション「＋」ボタン押下 → 新規PaymentDetail遷移要求

MarkDetailOpenPaymentByIdDelegate(String paymentId)
  - 支払セクション既存カードタップ → PaymentDetail編集遷移要求
```

### 3.2 State 変更

```dart
class MarkDetailState {
  // 既存フィールド...

  // 追加: このMarkに紐づく支払い一覧（PaymentInfoと同様の Projection）
  final PaymentSectionProjection paymentSection;
}
```

### 3.3 Event 追加

```dart
// 追加
class MarkDetailPaymentPlusTapped extends MarkDetailEvent
class MarkDetailPaymentTapped extends MarkDetailEvent { final String paymentId; }
class MarkDetailPaymentsUpdated extends MarkDetailEvent { final List<PaymentDomain> allPayments; }
```

### 3.4 Bloc 変更

- `Started` ハンドラ: `allPayments` を受け取り、`markLinkID == _markLinkId` でフィルタして `paymentSection` を生成
- `MarkDetailPaymentsUpdated`: EventDomain の payments が更新されるたびに呼ばれる
- `MarkDetailPaymentPlusTapped`: `MarkDetailOpenPaymentNewDelegate(markLinkId: _markLinkId)` を emit
- `MarkDetailPaymentTapped`: `MarkDetailOpenPaymentByIdDelegate(paymentId)` を emit

---

## 4. LinkDetailFeature 変更

MarkDetailFeature と同様の変更を LinkDetailFeature にも適用する。

### 追加 Delegate

```dart
LinkDetailOpenPaymentNewDelegate(String markLinkId)
LinkDetailOpenPaymentByIdDelegate(String paymentId)
```

### 追加 Event

```dart
LinkDetailPaymentPlusTapped
LinkDetailPaymentTapped { final String paymentId; }
LinkDetailPaymentsUpdated { final List<PaymentDomain> allPayments; }
```

### 追加 State フィールド

```dart
final PaymentSectionProjection paymentSection;
```

---

## 5. PaymentSectionProjection（新規）

MarkDetail / LinkDetail の支払セクション用表示モデル。

```dart
class PaymentSectionProjection extends Equatable {
  final List<PaymentItemProjection> items;  // PaymentInfoで使用中のモデルを流用
  final String displayTotalAmount;          // 例: "3,000円"
}
```

- `PaymentItemProjection` は既存の `PaymentInfoFeature` のものを流用

---

## 6. 保存フロー（PaymentDetail → MarkDetail/LinkDetail 連動保存）

### 6.1 MarkDetail/LinkDetail から PaymentDetail を開く

```
MarkDetailPage 支払「＋」タップ
↓
MarkDetailBloc emit MarkDetailOpenPaymentNewDelegate(markLinkId)
↓
MichiInfoPage（BlocListener）がハンドル
↓
PaymentDetailArgs(eventId, markLinkID: markLinkId) を生成
↓
router.push('/payment-detail', extra: args)
```

### 6.2 PaymentDetail 保存時のフロー

```
PaymentDetailPage 保存ボタン
↓
PaymentDetailBloc emit PaymentDetailSavedDelegate(draft)
  ※ draft.markLinkID が非 null の場合はその値を保持
↓
EventDetailBloc が PaymentDetailSavedDelegate をハンドル:
  1. payment を保存（markLinkID 付き）
  2. draft.markLinkID が非 null なら:
     - 対応する MarkDetail/LinkDetail の現在の Draft を保存
  3. router.pop() で PaymentDetail を閉じる → MarkDetail/LinkDetail 画面に戻る
```

### 6.3 既存の PaymentInfo からの登録フロー（変更なし）

`PaymentDetailArgs.markLinkID == null` のまま従来通り動作する。

---

## 7. カスケード削除

### Repository 変更

`EventRepository.deleteMarkLink(String markLinkId)` の実装に以下を追加:

```
MarkLink を論理削除する前に:
  markLinkID == markLinkId の Payment を全件論理削除（isDeleted = true）する
```

- drift トランザクション内で実行する
- 削除後、EventDomain.payments が更新され PaymentInfo・MarkDetail/LinkDetail 両方の表示から消える

---

## 8. PaymentInfoProjection 変更（グルーピング対応）

### 8.1 新 Projection 構造

```dart
// 変更後のトップレベル Projection
class PaymentInfoProjection extends Equatable {
  final List<PaymentDateGroupProjection> dateGroups;
  final List<PaymentItemProjection> directItems;  // markLinkID = null の支払い
  final String displayTotalAmount;
}

// 日付グループ
class PaymentDateGroupProjection extends Equatable {
  final String displayDate;   // "2026/04/15"
  final List<PaymentNameGroupProjection> nameGroups;
}

// 名称（MarkDetail/LinkDetail）グループ
class PaymentNameGroupProjection extends Equatable {
  final String markLinkId;
  final String displayName;   // markLinkName（null の場合は "名称なし"）
  final List<PaymentItemProjection> items;
  final String displayGroupTotal;  // グループ内合計金額
}
```

### 8.2 PaymentInfoProjectionAdapter 変更

```
入力: EventDomain（payments + markLinks）

1. isDeleted == false の payments を抽出
2. markLinkID != null の payments:
   a. markLinkID で MarkLinkDomain を引く
   b. markLinkDate の日付（yyyy/MM/dd）でグループ化 → PaymentDateGroupProjection
   c. 各日付グループ内で markLinkID ごとにサブグループ → PaymentNameGroupProjection
   d. markLinkDate 昇順でソート
3. markLinkID == null の payments:
   → directItems へ（paymentSeq 昇順）
4. 合計金額 = 全 payments の paymentAmount sum
```

### 8.3 PaymentInfoPage の表示変更

```
日付セクション（PaymentDateGroupProjection）
  └── 名称サブセクション（PaymentNameGroupProjection）
        └── 支払いカード（PaymentItemProjection）

「直接登録」セクション（directItems が空でない場合のみ表示）
  └── 支払いカード

合計金額フッター
```

---

## 9. MarkDetailPage / LinkDetailPage UI 変更

### 支払セクション仕様

- 既存セクション（基本情報・アクション等）の下部に追加
- セクションヘッダー: 「支払い」
- セクション右上: 「＋」ボタン（`Key('payment_plus_button')`)
- 支払いカードリスト: `PaymentSectionProjection.items` を表示（PaymentInfoと同様の `PaymentItemRow`）
- 合計金額: セクション下部に `PaymentSectionProjection.displayTotalAmount`
- items が空の場合: カードなし・合計金額表示なし（「＋」ボタンのみ）

---

## 10. テストシナリオ

### Integration Test: TC-PML-I001〜I010

| ID | シナリオ | 確認内容 |
|---|---|---|
| TC-PML-I001 | MarkDetail 支払セクションが表示される | 支払セクション・「＋」ボタンが表示される |
| TC-PML-I002 | MarkDetail「＋」から PaymentDetail に遷移できる | PaymentDetail 画面に遷移する |
| TC-PML-I003 | PaymentDetail を保存すると MarkDetail の支払セクションに追加される | 支払いカードが表示される |
| TC-PML-I004 | PaymentDetail 保存後に MarkDetail 画面に戻る | MarkDetail 画面が表示されている |
| TC-PML-I005 | MarkDetail の支払いは PaymentInfo タブにも表示される | PaymentInfo タブに同じ支払いが表示される |
| TC-PML-I006 | PaymentInfo から MarkDetail 経由の支払いを編集できる | 編集後の金額が PaymentInfo・MarkDetail 両方に反映される |
| TC-PML-I007 | PaymentInfo から MarkDetail 経由の支払いを削除できる | MarkDetail の支払セクションからも消える |
| TC-PML-I008 | LinkDetail でも同様の支払い登録ができる | LinkDetail の支払セクションから PaymentDetail 登録・表示 |
| TC-PML-I009 | MarkDetail を削除すると紐づく支払いも削除される | PaymentInfo タブからも消える |
| TC-PML-I010 | 直接登録の支払い（PaymentInfo タブ）は「直接登録」セクションに表示される | markLinkID = null の支払いが直接登録セクションに表示 |

---

## 11. 影響ファイル一覧

| ファイル | 変更内容 |
|---|---|
| `domain/transaction/payment/payment_domain.dart` | `markLinkID: String?` 追加 |
| `repository/impl/drift/tables.dart`（または同等） | `PaymentTable` に `markLinkID` カラム追加 |
| `repository/impl/drift/event_repository_impl.dart` | `deleteMarkLink` にカスケード削除追加、`markLinkID` 対応保存 |
| `features/payment_detail/draft/payment_detail_draft.dart` | `markLinkID: String?` 追加 |
| `features/payment_detail/payment_detail_args.dart` | `markLinkID: String?` 追加 |
| `features/payment_detail/bloc/payment_detail_bloc.dart` | `markLinkID` を Draft に保持 |
| `features/mark_detail/bloc/mark_detail_state.dart` | Delegate 2件追加、`paymentSection` フィールド追加 |
| `features/mark_detail/bloc/mark_detail_event.dart` | Event 3件追加 |
| `features/mark_detail/bloc/mark_detail_bloc.dart` | 支払セクションハンドラ追加 |
| `features/mark_detail/view/mark_detail_page.dart` | 支払セクション UI 追加、Delegate ハンドラ追加 |
| `features/link_detail/bloc/link_detail_state.dart` | Delegate 2件追加、`paymentSection` フィールド追加 |
| `features/link_detail/bloc/link_detail_event.dart` | Event 3件追加 |
| `features/link_detail/bloc/link_detail_bloc.dart` | 支払セクションハンドラ追加 |
| `features/link_detail/view/link_detail_page.dart` | 支払セクション UI 追加、Delegate ハンドラ追加 |
| `features/event_detail/bloc/event_detail_bloc.dart` | PaymentDetailSavedDelegate の markLinkID 連動保存追加 |
| `features/michi_info/view/michi_info_page.dart` | MarkDetail/LinkDetail Delegate（支払遷移）ハンドラ追加 |
| `features/event_detail/projection/payment_info_projection.dart` | グルーピング対応 Projection モデルに変更 |
| `features/event_detail/adapter/payment_info_projection_adapter.dart` | グルーピングロジック追加 |
| `features/payment_info/view/payment_info_view.dart` | グルーピング表示対応 |
| `app/router.dart` | PaymentDetailArgs.markLinkID 対応 |
