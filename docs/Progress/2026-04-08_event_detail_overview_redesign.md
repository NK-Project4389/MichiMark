# 進捗: EventDetail 概要タブ再設計

日付: 2026-04-08

---

## 背景

EventDetail の保存操作が不揃い（BasicInfo はチェックボタン、MichiInfo/PaymentInfo はネスト先保存）という UX 課題を解消するため、タブ構成を再設計した。

---

## 完了した作業

### 設計フェーズ
- バグ調査: MichiInfo 地点追加の DB 保存なし・PaymentInfo await 漏れを特定
- UX 議論: 一貫性 vs ネスト 2 段階保存の問題を整理
- 要件書作成: `docs/Requirements/REQ-event_detail_overview_redesign.md`
- Spec 作成: `docs/Spec/Features/EventDetailOverviewRedesign_Spec.md`

### 実装フェーズ（T-091）

#### Step 1: MarkDetail / LinkDetail 即 DB 保存
- `_eventId` 保持追加
- `_onSaveTapped` に DB 保存ロジック追加
- `MarkDetailSavedDelegate` / `LinkDetailSavedDelegate` に変更
- `isSaving` フラグ追加

#### Step 2: PaymentDetail 即 DB 保存
- `_eventId` 保持追加
- `_onSaveTapped` に DB 保存ロジック追加
- `PaymentDetailSavedDelegate` に変更
- `PaymentInfoView` を `StatefulWidget` 化・`await context.push` 対応
- `PaymentInfoBloc` に `PaymentInfoReloadRequested` 追加

#### Step 3: BasicInfo インライン編集
- `BasicInfoDraft.isEditing` フラグ追加
- `BasicInfoBloc` に `_onEditModeEntered` / `_onSavePressed` / `_onEditCancelled` 追加
- `BasicInfoBloc` が直接 DB 保存（`EventDetailBloc._onSaveRequested` から移管）
- `BasicInfoSavedDelegate` 追加
- `BasicInfoView` に参照モード / 編集モード UI 追加

#### Step 4: EventDetail タブ構成変更
- `EventDetailTab` を `overview / michiInfo / paymentInfo` の 3 値に変更
- AppBar チェックボタン削除
- `EventDetailSaveRequested` / `EventDetailSavedDelegate` 削除
- 概要タブ = BasicInfoSection（上部）+ OverviewSection（下部）
- タブ切り替えアラート実装（「保存して移動」「破棄して移動」「編集に戻る」）
- `EventDetailDelegateConsumed` 追加・delegate null リセット

### バグ修正（レビュー・テスト指摘対応）
- `EventDetailBloc._onDelegateConsumed` で `delegate: null` 明示
- `BasicInfoView` の不要な `_eventId` フィールド削除
- async gap 後の `context.mounted` チェック追加
- `basic_info_view.dart` / `moving_cost_overview_view.dart` / `travel_expense_overview_view.dart` の ListView に `shrinkWrap: true` + `NeverScrollableScrollPhysics` 追加
- `_TabButton` を `BlocBuilder<BasicInfoBloc>` でラップ（isEditing 反映）
- アラートタイトルを「保存していません」に統一
- アラートキャンセルボタンを「編集に戻る」に変更（BasicInfoForm の「キャンセル」と区別）

### テスト（T-093）
- `flutter/integration_test/event_detail_overview_redesign_test.dart` 作成
- **12 PASS / 3 SKIP / 0 FAIL**
- SKIP 3 件（TC-EOD-010, 011, 012）はシードデータ未整備のため許容（T-080 対応後に確認予定）

---

## 未完了・次回やること

- [ ] **TC-EOD-010, 011, 012 の確認**: T-080（シードデータ更新）完了後に再テスト
- [ ] **T-073〜076**: 地点追加初期値・引き継ぎ Spec → 実装（T-073 architect TODO）
- [ ] **T-070〜072**: MichiInfo 日付セパレーター Spec → 実装
- [ ] **T-080**: シードデータ更新

## 次回セッションで最初にやること

1. **T-073 architect**: 地点追加初期値・引き継ぎの Spec 作成（REQ-mark_addition_defaults）
2. **T-080 flutter-dev**: シードデータ更新（TC-EOD-010, 011, 012 の SKIP 解消も兼ねる）
