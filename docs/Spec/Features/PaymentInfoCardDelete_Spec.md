# Feature Spec: PaymentInfo 伝票削除機能

- **Spec ID**: PaymentInfoCardDelete_Spec
- **要件ID**: REQ-payment_info_card_delete
- **作成日**: 2026-04-11
- **担当**: architect
- **ステータス**: 確定

---

## 1. 概要

PaymentInfo（支払タブ）の伝票行（`_PaymentListTile` 1行）を左スワイプで削除できるようにする。
削除は `payments` テーブルの論理削除（`is_deleted = true`）＋ `payment_split_members` の物理削除。
削除後はリストと合計金額を即時再計算する。

---

## 2. 変更対象一覧

| 層 | ファイル | 変更種別 |
|---|---|---|
| Repository（I/F） | `flutter/lib/repository/event_repository.dart` | メソッド追加 |
| Repository（Drift実装） | `flutter/lib/repository/impl/drift/dao/event_dao.dart` | メソッド追加 |
| Repository（Drift実装） | `flutter/lib/repository/impl/drift/repository/drift_event_repository.dart` | メソッド追加 |
| Repository（InMemory実装） | `flutter/lib/repository/impl/in_memory/in_memory_event_repository.dart` | メソッド追加 |
| Bloc Event | `flutter/lib/features/payment_info/bloc/payment_info_event.dart` | Event クラス追加 |
| Bloc | `flutter/lib/features/payment_info/bloc/payment_info_bloc.dart` | ハンドラー追加 |
| View | `flutter/lib/features/payment_info/view/payment_info_view.dart` | Slidable ラップ追加 |

---

## 3. Repository 変更

### 3.1 EventRepository（I/F）追加メソッド

`flutter/lib/repository/event_repository.dart` に以下を追加する：

```dart
/// Payment（伝票）を論理削除し、関連する payment_split_members を物理削除する
Future<void> deletePayment(String paymentId);
```

### 3.2 Drift DAO 実装

`event_dao.dart` に追加するメソッド：

```dart
Future<void> deletePayment(String paymentId) async {
  final now = DateTime.now();
  await transaction(() async {
    // 1. payment_split_members 物理削除
    await (delete(paymentSplitMembers)
          ..where((t) => t.paymentId.equals(paymentId)))
        .go();
    // 2. payments 論理削除
    await (update(payments)
          ..where((t) => t.id.equals(paymentId)))
        .write(PaymentsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ));
  });
}
```

テーブル名・Companion 名は既存コードから確認して合わせること。

### 3.3 Drift Repository 実装

`drift_event_repository.dart` に追加：

```dart
@override
Future<void> deletePayment(String paymentId) =>
    _eventDao.deletePayment(paymentId);
```

### 3.4 InMemory 実装

`in_memory_event_repository.dart` に追加（テスト用）：

```dart
@override
Future<void> deletePayment(String paymentId) async {
  // 全イベントを走査して該当 paymentId の PaymentDomain を isDeleted = true に更新
  // 実装は flutter-dev に委ねる
}
```

---

## 4. Bloc Event 追加

`payment_info_event.dart` に追加：

```dart
/// 伝票の削除ボタンがタップされたとき
class PaymentInfoPaymentDeleteRequested extends PaymentInfoEvent {
  final String paymentId;
  const PaymentInfoPaymentDeleteRequested(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}
```

---

## 5. Bloc ハンドラー追加

`PaymentInfoBloc` に追加。`EventRepository` は既に DI 注入済みのため変更不要。

コンストラクタ登録：
```dart
on<PaymentInfoPaymentDeleteRequested>(_onPaymentDeleteRequested);
```

ハンドラー実装：

```dart
Future<void> _onPaymentDeleteRequested(
  PaymentInfoPaymentDeleteRequested event,
  Emitter<PaymentInfoState> emit,
) async {
  if (state case PaymentInfoLoaded current) {
    try {
      // 1. DB 論理削除
      await _eventRepository.deletePayment(event.paymentId);
      // 2. DB から projection を再取得（_onReloadRequested と同じパターン）
      final domain = await _eventRepository.fetch(_eventId);
      final projection = EventDetailAdapter.toProjection(domain).paymentInfo;
      emit(current.copyWith(projection: projection));
    } on Exception {
      // サイレント失敗（既存の projection を維持）
    }
  }
}
```

**注意**: `PaymentInfoBloc` が `_eventId` を保持するフィールドを使っていることを確認すること。
`PaymentInfoStarted` で `_eventId` を設定しているパターンに合わせる。

---

## 6. View 変更

### 6.1 import 追加

```dart
import 'package:flutter_slidable/flutter_slidable.dart';
```

### 6.2 Slidable ラップ

`_PaymentInfoList` の `ListView.separated` の `itemBuilder` 内で
`_PaymentListTile` を `Slidable` でラップする。

**Key 命名規則（設計憲章 §Widget Key 命名規則に準拠）**:
- Slidable: `Key('payment_info_tile_slidable_${item.id}')`
- 削除アクション: `Key('payment_info_tile_delete_action_${item.id}')`

```dart
Slidable(
  key: Key('payment_info_tile_slidable_${item.id}'),
  endActionPane: ActionPane(
    motion: const DrawerMotion(),
    extentRatio: 0.25,
    children: [
      SlidableAction(
        key: Key('payment_info_tile_delete_action_${item.id}'),
        onPressed: (_) => context
            .read<PaymentInfoBloc>()
            .add(PaymentInfoPaymentDeleteRequested(item.id)),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: '削除',
      ),
    ],
  ),
  child: _PaymentListTile(item: item),
)
```

---

## 7. PaymentInfoBloc の _eventId 確認

`PaymentInfoBloc` が `_eventId` フィールドを持つかどうかを確認する。
持っていない場合は `PaymentInfoStarted` ハンドラーで `_eventId = event.eventId` を設定するよう追加する。

---

## 8. テストシナリオ

Integration Test グループ `TC-PID`（Payment Info Delete）

### 前提条件

- シードデータで対象イベントに伝票が複数件存在する
- 各テストで個別に `app.main()` を呼び出す

---

### TC-PID-001: 伝票行を左スワイプすると削除ボタンが表示される

**手順**:
1. PaymentInfo 画面（支払タブ）を表示する
2. 伝票行を左スワイプする

**期待**: `Key('payment_info_tile_delete_action_${paymentId}')` を持つ赤い削除ボタンが表示される

---

### TC-PID-002: 削除ボタンをタップすると伝票が一覧から消える

**前提**: 伝票が 2 件以上存在する

**手順**:
1. PaymentInfo 画面を表示する
2. 伝票行の 1 つを左スワイプして削除ボタンをタップする

**期待**:
- 削除した伝票行が一覧に表示されなくなる
- 他の伝票行は引き続き表示されている

---

### TC-PID-003: 削除後に合計金額が再計算される

**前提**: 伝票が 2 件以上存在し、合計金額が表示されている

**手順**:
1. PaymentInfo 画面を表示して合計金額を確認する
2. 伝票行の 1 つを左スワイプして削除する

**期待**: 合計金額が削除後の残伝票を元に再計算された値に更新される

---

### TC-PID-004: 最後の 1 件を削除すると空状態 UI が表示される

**前提**: シードデータに伝票が 1 件のみのイベントを使用する

**手順**:
1. PaymentInfo 画面を表示する（伝票 1 件）
2. その伝票を左スワイプして削除する

**期待**: 「支払情報がありません」の空状態 UI が表示される

---

### TC-PID-005: 削除後に確認ダイアログが表示されない

**手順**:
1. PaymentInfo 画面を表示する
2. 伝票行を左スワイプして削除ボタンをタップする

**期待**: AlertDialog / ConfirmationDialog が表示されない（即座に削除される）

---

## 9. 対象外

- 削除取り消し（Undo）
- 物理削除
- payment_split_members 単体の削除
- 概要タブ（TravelExpenseOverview）の精算セクションへの即時反映（リロード時に反映される）
