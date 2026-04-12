# Feature Spec: PaymentInfo 削除アイコン常時表示（UI-4）

- **Spec ID**: FS-payment_info_delete_icon
- **要件ID**: REQ-payment_info_delete_icon
- **作成日**: 2026-04-12
- **担当**: architect
- **ステータス**: 確定

---

## 1. Feature Overview

### Feature Name

payment_info（削除UI変更）

### Purpose

PaymentInfoカード（伝票行）の削除操作を、`flutter_slidable` スワイプ方式から削除アイコン常時表示方式に変更する。

MichiInfo（UI-3）と削除アイコンのデザインを統一し、UIの一貫性を確保する。
スワイプへの気づきにくさを解消し、削除操作を直感的にする。

### Scope

含むもの
- `flutter_slidable` を使ったスワイプ削除UIの撤去（`SlidableAutoCloseBehavior` / `Slidable` / `SlidableAction` の除去）
- `_PaymentListTile` 右端への削除アイコン常時表示
- 削除アイコンタップによる即削除（確認ダイアログなし）

含まないもの
- 削除ロジック・Repository層の変更（既存実装 `PaymentInfoCardDelete_Spec` を流用）
- 削除取り消し（Undo）
- 確認ダイアログの追加
- MichiInfo側のUI変更

---

## 2. Feature Responsibility

このFeatureの責務（変更なし）

- Draft所有（PaymentInfoはProjectionのみ保持・Draftなし）
- Projection表示
- 削除Event発火（Bloc経由）
- Navigation通知（Delegate経由）

RootはこのFeatureの内部状態を変更しない。

---

## 3. State Structure

既存の `PaymentInfoState` を変更なしで流用する。

| State | フィールド | 説明 |
|---|---|---|
| `PaymentInfoLoading` | なし | 読み込み中 |
| `PaymentInfoLoaded` | `projection: PaymentInfoProjection`, `eventId: String`, `delegate: PaymentInfoDelegate?` | 表示状態 |
| `PaymentInfoError` | `message: String` | エラー状態 |

---

## 4. Draft Model

PaymentInfo Featureは編集Draftを持たない（表示専用）。変更なし。

---

## 5. Domain Model

`PaymentDomain` を変更なしで流用する。削除ロジックはRepositoryの `deletePayment(paymentId)` を使用する（既存実装）。

---

## 6. Projection Model

既存の `PaymentInfoProjection` / `PaymentItemProjection` を変更なしで流用する。

| Projection | フィールド | 説明 |
|---|---|---|
| `PaymentInfoProjection` | `items: List<PaymentItemProjection>`, `displayTotalAmount: String` | 一覧表示用 |
| `PaymentItemProjection` | `id: String`, `displayAmount: String`, `payer: MemberProjection`, `splitMembers: List<MemberProjection>`, `memo: String?` | 伝票行表示用 |

---

## 7. Adapter

変更なし。既存の `EventDetailAdapter.toProjection()` を流用する。

---

## 8. Events

既存の `PaymentInfoPaymentDeleteRequested` を変更なしで流用する。新規Eventの追加なし。

| Event | 発火タイミング | 説明 |
|---|---|---|
| `PaymentInfoStarted` | 画面表示時 | Projectionを親から注入して初期化 |
| `PaymentInfoPaymentTapped` | 伝票行タップ時 | 編集画面への遷移を要求 |
| `PaymentInfoPlusButtonTapped` | FABタップ時 | 新規作成画面への遷移を要求 |
| `PaymentInfoPaymentDeleteRequested` | 削除アイコンタップ時 | 対象伝票の削除を要求（変更なし・トリガー元がスワイプ→アイコンに変わる） |
| `PaymentInfoDelegateConsumed` | Delegate処理後 | Delegateクリア |
| `PaymentInfoReloadRequested` | PaymentDetail画面から戻った後 | Projectionの再取得 |

---

## 9. Delegate Contract

変更なし。既存Delegateを流用する。

| Delegate | 遷移先・処理 |
|---|---|
| `PaymentInfoOpenNewPaymentDelegate` | `/event/payment`（新規作成） |
| `PaymentInfoOpenPaymentByIdDelegate` | `/event/payment`（既存編集） |
| `PaymentInfoReloadedDelegate` | EventDetailPageのBlocListenerがcachedEventを更新 |

---

## 10. Bloc Responsibility

`PaymentInfoBloc` の変更なし。`_onPaymentDeleteRequested` ハンドラーは既存実装を流用する。

Blocは以下のみ行う
- Projection更新（削除後の再fetch）
- Delegate発火（遷移通知）

禁止事項
- Repository直接操作（DI経由のみ）
- Navigation操作

---

## 11. View 変更仕様

### 11.1 変更対象

`flutter/lib/features/payment_info/view/payment_info_view.dart`

### 11.2 撤去するUI要素

- `SlidableAutoCloseBehavior` ラッパー
- `Slidable` ウィジェット
- `ActionPane` / `SlidableAction`（削除ボタン）
- `flutter_slidable` の import

### 11.3 追加するUI要素（削除アイコン）

`_PaymentListTile` の右端に削除アイコンボタンを常時表示する。

**デザイン仕様（MichiInfo UI-3 統一）:**

| 要素 | 値 |
|---|---|
| アイコン | `Icons.delete` |
| アイコン色 | `#DC2626` |
| 背景色 | `#FEE2E2` |
| 形状 | 角丸（`BorderRadius.circular(8)`) |
| サイズ | 横幅 `44px`・縦幅カードの縦サイズに合わせる（`constraints: BoxConstraints.expand(width: 44)`） |
| 配置 | `Row` の末尾（`_PaymentListTile` 内の行末） |

### 11.4 タップ動作

削除アイコンタップ時に `PaymentInfoPaymentDeleteRequested(item.id)` を発火する。確認ダイアログは表示しない。

---

## 12. Data Flow

```
ユーザーが削除アイコンをタップ
  ↓
PaymentInfoPaymentDeleteRequested(paymentId) → PaymentInfoBloc
  ↓
EventRepository.deletePayment(paymentId)（論理削除）
  ↓
EventRepository.fetch(eventId)（再fetch）
  ↓
EventDetailAdapter.toProjection() → PaymentInfoProjection
  ↓
PaymentInfoLoaded(projection: 更新後) emit
  ↓
_PaymentInfoList が再描画（削除済み伝票が消え・合計金額が更新）
```

---

## 13. Router変更方針

変更なし。

---

## 14. Widget Key 命名規則

| ウィジェット | Key |
|---|---|
| 削除アイコンボタン（各伝票行） | `Key('paymentInfo_button_delete_${item.id}')` |

---

## 15. テストシナリオ

Integration Test グループ `TC-PID2`（Payment Info Delete Icon）

### 前提条件

- シードデータで対象イベントに伝票が複数件存在する
- 各 `testWidgets` で個別に `app.main()` を呼び出す（`setUpAll` での起動は使わない）

### テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-PID2-001 | スワイプ操作で削除UIが表示されない | High |
| TC-PID2-002 | カード右端に削除アイコンが常時表示されている | High |
| TC-PID2-003 | 削除アイコンタップで即削除される（ダイアログなし） | High |

---

### TC-PID2-001: スワイプ操作で削除UIが表示されない

**前提:**
- PaymentInfo 画面（支払タブ）に伝票が1件以上存在する

**手順:**
1. PaymentInfo 画面を表示する
2. 伝票行を左スワイプする

**期待結果:**
- スワイプ後も削除ボタン（`SlidableAction`）が表示されない
- 伝票行は変化なく表示され続ける

**実装ノート:**
- `Key('payment_info_tile_slidable_${paymentId}')` が存在しないことを確認する
- スワイプ操作後に `find.text('削除')` が表示されていないことを確認する

---

### TC-PID2-002: カード右端に削除アイコンが常時表示されている

**前提:**
- PaymentInfo 画面（支払タブ）に伝票が1件以上存在する

**手順:**
1. PaymentInfo 画面を表示する
2. 伝票リストを確認する

**期待結果:**
- 各伝票行の右端に削除アイコンボタンが表示されている
- アイコンはゴミ箱（`Icons.delete`）であり、赤色（`#DC2626`）で表示されている
- スワイプ等の操作なしに最初から表示されている

**実装ノート:**
- 対象 Key: `Key('paymentInfo_button_delete_${paymentId}')`
- `find.byKey(Key('paymentInfo_button_delete_${paymentId}'))` が `findsOneWidget` であること

---

### TC-PID2-003: 削除アイコンタップで即削除される（ダイアログなし）

**前提:**
- PaymentInfo 画面（支払タブ）に伝票が2件以上存在する
- 削除する伝票の `paymentId` が既知である

**手順:**
1. PaymentInfo 画面を表示する
2. 削除対象伝票の `Key('paymentInfo_button_delete_${paymentId}')` をタップする

**期待結果:**
- AlertDialog / ConfirmationDialog が表示されない（即座に削除処理が走る）
- 削除した伝票行が一覧に表示されなくなる
- 他の伝票行は引き続き表示されている
- 合計金額が削除後の残伝票をもとに再計算された値に更新されている

**実装ノート:**
- タップ後 `find.byType(AlertDialog)` が `findsNothing` であること
- `find.byKey(Key('paymentInfo_button_delete_${paymentId}'))` が `findsNothing` になること（行が消えたことの確認）
- `find.byKey(Key('paymentInfo_button_delete_${otherPaymentId}'))` が `findsOneWidget` のまま残ること

---

## 16. 対象外

- 削除ロジック・Repository層の変更
- 削除取り消し（Undo）
- 確認ダイアログの追加
- MichiInfo側のUI変更
- `flutter_slidable` パッケージ自体の `pubspec.yaml` からの除去（他Feature（MichiInfo）が引き続き使用）

---

## 17. 既存Spec参照

削除ロジック（Repository・Bloc）の詳細は `docs/Spec/Features/PaymentInfoCardDelete_Spec.md` を参照すること。

---

## End of Spec
