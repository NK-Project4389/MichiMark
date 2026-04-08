# 進捗: PaymentInfo UI 改善 + 支払いごとの精算セクション追加

**日付**: 2026-04-09
**Spec**: `docs/Spec/Features/PaymentInfoRedesign_Spec.md`

---

## 完了した作業

### 実装（flutter-dev）

1. **`flutter/lib/features/payment_info/view/payment_info_view.dart`**
   - `_PaymentListTile` を多行レイアウトに刷新
   - 行1: 金額テキスト（`bodyLarge` + Bold）
   - 行2: "支払" ラベル（プレーン）+ 支払者チップ（Teal `#2B7A9B` 背景・白テキスト）
   - 行3: "割り勘" ラベル（プレーン）+ 割り勘メンバーチップ（Emerald `#2E9E6B` 背景・Wrap 折り返し、splitMembers.isNotEmpty のときのみ）
   - 行4: メモ（bodySmall・italic・onSurfaceVariant、memo != null && memo.isNotEmpty のときのみ）
   - `_MemberChip` 新規 Widget 追加

2. **`flutter/lib/adapter/travel_expense_overview_adapter.dart`**
   - `SettlementLineProjection` 新規定義（payerName / receiverName / displayAmount）
   - `PerPaymentSettlementProjection` 新規定義（displayTitle / displayAmount / lines）
   - `TravelExpenseOverviewProjection` に `perPaymentSettlements` フィールド追加
   - `PerPaymentSettlementAdapter` 新規クラス追加（均等割り計算・isDeleted除外・paymentSeq昇順・splitMembers空は除外）
   - `TravelExpenseOverviewAdapter.toProjection` に `PerPaymentSettlementAdapter.toProjections` 呼び出し追加

3. **`flutter/lib/features/overview/view/travel_expense_overview_view.dart`**
   - 「収支バランス」直下に「支払いごとの精算」セクション追加
   - `perPaymentSettlements.isEmpty` 時はセクション非表示
   - `_PerPaymentSettlementCard` 新規 Widget 追加（ヘッダー行: タイトル左 + 金額右・Teal tint）
   - `_SettlementLineRow` 新規 Widget 追加（payerName: error色・receiverName: green.shade700・金額: デフォルト）

### テスト（tester）

- `flutter/integration_test/payment_info_redesign_test.dart` 新規作成
- TC-PIR-001 〜 TC-PIR-014 全14件 PASS

---

## 未完了

なし

---

## 次回セッションで最初にやること

- `docs/Tasks/TASKBOARD.md` を確認してタスクを確認する
