# POST-1/F-5 MarkDetail/LinkDetailからPaymentDetail登録 実装完了

**日時:** 2026-04-16
**タスク:** FS-payment_from_mark_link
**状態:** 実装完了・dart analyze エラーゼロ確認・push 完了

---

## 完了した作業

### Domain 変更
- `payment_domain.dart` に `markLinkID: String?` フィールド追加

### Repository 変更
- `event_tables.dart` の `Payments` テーブルに `mark_link_id` カラム追加
- `database.dart` の schemaVersion を 4 → 5 に変更・ALTER TABLE マイグレーション追加
- `event_dao.dart` の `_buildPaymentDomain`/`_toPaymentCompanion` に `markLinkID` 対応
- `event_dao.dart` の `deleteMarkLink` にカスケード削除（紐づく Payment の論理削除）追加

### PaymentDetail 変更
- `payment_detail_draft.dart` に `markLinkID: String?` 追加
- `payment_detail_args.dart` に `markLinkID: String?` 追加
- `payment_detail_event.dart` の `PaymentDetailStarted` に `markLinkID` 追加
- `payment_detail_bloc.dart` で `markLinkID` を Draft・Domain に保持

### 新規追加ファイル
- `lib/features/shared/projection/payment_section_projection.dart`（PaymentSectionProjection）
- `lib/adapter/payment_section_projection_adapter.dart`（PaymentSectionProjectionAdapter）

### MarkDetail 変更
- State に `paymentSection: PaymentSectionProjection` / `eventId: String` 追加
- Delegate に `MarkDetailOpenPaymentNewDelegate` / `MarkDetailOpenPaymentByIdDelegate` 追加
- Event に `MarkDetailPaymentPlusTapped` / `MarkDetailPaymentTapped` / `MarkDetailPaymentsUpdated` / `MarkDetailPaymentsReloadRequested` 追加
- Bloc で支払セクションハンドラ実装
- View（mark_detail_page.dart）に `_PaymentSection` / `_PaymentItemRow` ウィジェット追加

### LinkDetail 変更
- State に `paymentSection` / `eventId` 追加
- Delegate に `LinkDetailOpenPaymentNewDelegate` / `LinkDetailOpenPaymentByIdDelegate` 追加
- Event に同様の 4件追加
- Bloc で支払セクションハンドラ実装
- View（link_detail_page.dart）に `_PaymentSection` / `_PaymentItemRow` ウィジェット追加

### PaymentInfo 変更（Spec §8）
- `PaymentInfoProjection` をグループ化対応に変更（`dateGroups: List<PaymentDateGroupProjection>` / `directItems: List<PaymentItemProjection>`）
- `EventDetailAdapter._toPaymentInfo` でグループ化ロジック実装
- `PaymentInfoView` をグループ化表示（日付セクション → 名称サブセクション → 支払いカード / 直接登録セクション）に更新

### Router 変更
- `router.dart` の `/event/payment` ルートで `markLinkID: args.markLinkID` を `PaymentDetailStarted` に渡すよう修正

---

## dart analyze 結果

- **error: 0 件**
- warning: 統合テストファイルの未使用要素（今回の変更とは無関係）のみ

---

## Integration Test 実装・実行結果（2026-04-16）

### テスト実装
- `flutter/integration_test/payment_from_mark_link_test.dart` 実装
- TC-PML-I001〜I010 全件実装

### バグ修正（テスト実行中に発見）

**バグ: PaymentDetailBloc `_onPayMemberChipToggled` で `markLinkID` が消失**

- 場所: `lib/features/payment_detail/bloc/payment_detail_bloc.dart`
- 原因: 支払いメンバーチップタップ時に `PaymentDetailDraft` を直接コンストラクタで再生成する際、`markLinkID` フィールドを渡していなかった
- 影響: MarkDetail から支払い登録すると `markLinkID = null` で保存され、MarkDetail の支払セクションに表示されなかった
- 修正: `final newDraft = PaymentDetailDraft(... markLinkID: draft.markLinkID)` に `markLinkID` 追加

**バグ修正: PaymentInfo タブの自動リロード（BlocListener 追加）**
- PaymentDetail から戻ったとき PaymentInfo タブが自動リロードされない問題
- `event_detail_page.dart` に `BlocListener` を追加してタブ切り替え時に `PaymentInfoReloadRequested` を発火

### テスト結果
- **15 PASS / 0 FAIL / 3 SKIP**（SKIP: LinkDetail関連テストはスキップ処理済み）
- T-363a・T-363b・T-364・T-365 全て DONE

---

## 次回セッションで最初にやること

- UI-14（MichiInfoタイムライン道路イメージ背景）実装: T-398a/b
  - Spec: `docs/Spec/Features/FS-michi_info_road_timeline.md`
- F-2（ダッシュボード）実装: T-392a/b
