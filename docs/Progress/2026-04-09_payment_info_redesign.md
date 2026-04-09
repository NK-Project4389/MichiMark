# 進捗: 2026-04-09 セッション（バグ修正・UI改善・ルール整備）

**日付**: 2026-04-09

---

## 完了した作業

### 1. グラデーション AppBar 戻るボタンバグ修正 (5b5136c)

- `event_detail_page.dart` Topic設定済みイベントの AppBar 戻るボタンが `EventDetailDismissPressed` を直接呼んでいた
- `_onBackPressed(context)` に修正 → 未保存ダイアログが正しく表示されるように
- TC-BACK-002, TC-BACK-003 PASS

### 2. PaymentInfo UI 改善 + 支払いごとの精算セクション追加 (c7353e3)

**Spec**: `docs/Spec/Features/PaymentInfoRedesign_Spec.md`

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

### 3. FuelDetailWidget デザイン修正（TC-FD-001〜004 PASS）

- `fuel_detail_widget.dart` の `_FuelTextField` が `OutlineInputBorder`（枠あり）だった
- `InputBorder.none` + 左120px ラベル行スタイルに変更（MarkDetail と統一）
- フィールド間を `Divider(height: 1)` で区切り
- `integration_test/fuel_detail_design_test.dart` 新規作成・全4件PASS

### 4. tester ルール整備 (5921119)

- `flutter test integration_test/` での全件実行が過剰だった（79件）
- 対象ファイルのみ実行を原則化
- 全件実行はリリース前・大きな構造変更後のみに限定
- `.claude/agents/tester.md` に明記

---

## 未完了 / 要対応

### 既存テスト失敗（UI変更に伴うテスト更新が必要）

| テストファイル | テストID | 原因 |
|---|---|---|
| `mark_addition_defaults_test.dart` | TC-MAD-006 | `IconButton.at(1)` でメンバー追加ボタンを探しているが UI 変更で順番が変わった |
| `mark_addition_defaults_test.dart` | TC-MAD-007 | AppBar の `Icons.check` 保存ボタンを探しているが概要タブ再設計で FAB に変更済み |
| `michi_info_layout_test.dart` | TS-03, TS-04 | Mark/Link タップ後の遷移確認テキストが UI 変更で変わった可能性 |

### 「給油計算」バグ
ユーザーから「給油計算がおかしい」と報告あり。FuelDetail の具体的な問題内容は未確認。

---

## 次回セッションで最初にやること

1. `docs/Tasks/TASKBOARD.md` を確認してタスクを確認する
2. 既存テスト失敗を修正する（TC-MAD-006/007、TS-03/04）
3. 「給油計算」バグの詳細をユーザーに確認する
