# Feature Spec: F-8 PaymentDetail 売上項目追加・OverView 収支合計表示

Platform: **Flutter / Dart**
Version: 1.0
Status: Draft
Created: 2026-04-18
Requirement: `docs/Requirements/REQ-payment_detail_sales.md`

---

# 1. Feature Overview

## Feature Name

PaymentDetailSales

## Purpose

`PaymentDomain` に売上/支出の区分フィールド（`PaymentType` enum）を追加し、visitWork トピックの OverView 集計セクションに売上・支出グループ別の項目一覧と収支合計を表示する。時給換算は `revenue` 種別のみの合計に変更する。visitWork の EventDetail 支払タブのラベルを「収支」に動的切り替えする。

## Scope

### 追加・変更するもの

| 分類 | 対象 |
|---|---|
| Domain | `PaymentType` enum 新規追加（`expense` / `revenue`） |
| Domain | `PaymentDomain` に `paymentType: PaymentType` フィールド追加 |
| Repository（drift） | `payments` テーブルに `payment_type` カラム追加（schemaVersion 8） |
| Adapter | `VisitWorkAggregationAdapter` の `revenue` 算出を `revenue` 種別のみに変更 |
| Adapter | `PaymentBalanceSectionAdapter` 新規追加（収支セクション向けデータ算出） |
| Projection | `PaymentBalanceSectionProjection` 新規追加（売上・支出グループ表示用） |
| Projection | `VisitWorkProjection` に収支セクション関連フィールドを追加 |
| View | `PaymentDetailPage` に「売上 / 支出」切り替え UI 追加 |
| View | `VisitWorkOverviewView` の「売上」セクションを「収支」セクションに拡張 |
| View | `EventDetailPage` の支払タブラベルを visitWork 時のみ「収支」に動的切り替え |

### 含まないもの

- visitWork 以外のトピック（travelExpense / movingCost）への収支表示拡張
- PaymentDomain への符号反転処理（売上は常に正の値のまま保存）
- markLinkID フィールドの変更（F-5 との独立共存を維持）

---

# 2. 設計判断

## 2-1. PaymentType enum の設計

`expense`（支出）をデフォルト値とする。

```
PaymentType.expense  // デフォルト。既存レコードはすべてこの種別として扱う
PaymentType.revenue  // 売上
```

- 既存 PaymentDomain はマイグレーション時に `expense` で初期化されるため後方互換性を保つ
- 金額の符号は扱わない。売上も支出も `paymentAmount` は正の整数で保存する
- 表示時にのみ符号（+/-）をつける（Projection 責務）

## 2-2. DB マイグレーション方針

- `schemaVersion` を `7 → 8` に変更する
- `payments` テーブルへの `ALTER TABLE` 追加のみ。既存テーブルのスキーマは変更しない
- デフォルト値は `'expense'` とする（`withDefault(const Constant('expense'))`）
- drift テーブル定義（`event_tables.dart`）の `Payments` クラスに `payment_type` カラムを追加する

## 2-3. タブ名動的切り替え方針

- `EventDetailPage` の `_TabButton` ウィジェット内で、`EventDetailBloc` の `topicConfig`（または `TopicType`）を参照し、visitWork の場合のみタブラベルを「収支」に変更する
- `_TabButton._label` の switch 文で `EventDetailTab.paymentInfo` case を分岐する
- タブのキー名・ルーティング・内部 Feature 名には影響を与えない
- `EventDetailLoaded` の `topicConfig` を `BlocBuilder` で参照して取得する

## 2-4. 時給換算の変更方針

- `VisitWorkAggregationAdapter.fromResults` が現行で `aggregation.totalPayment`（全 PaymentDomain 合計）を `revenue` に渡している
- 本 Feature 完了後は `revenue` 種別の PaymentDomain のみの合計を渡すよう変更する
- 変更箇所: `flutter/lib/adapter/visit_work_aggregation_adapter.dart`
- 変更対象フィールド: `revenue` 引数

---

# 3. Domain 変更

## 3-1. PaymentType enum（新規）

**ファイル:** `flutter/lib/domain/transaction/payment/payment_type.dart`

| 値 | 意味 | デフォルト |
|---|---|---|
| `expense` | 支出（経費） | true |
| `revenue` | 売上（収入） | false |

## 3-2. PaymentDomain の変更

**ファイル:** `flutter/lib/domain/transaction/payment/payment_domain.dart`

追加フィールド:

| フィールド名 | 型 | 説明 |
|---|---|---|
| `paymentType` | `PaymentType` | 支払種別。デフォルト `PaymentType.expense` |

- `props` リストに `paymentType` を追加する
- `copyWith` に `PaymentType? paymentType` を追加する
- コンストラクタのデフォルト: `this.paymentType = PaymentType.expense`

---

# 4. Repository（drift）変更

## 4-1. event_tables.dart

**ファイル:** `flutter/lib/repository/impl/drift/tables/event_tables.dart`

`Payments` テーブルに追加するカラム:

| カラム名 | drift 型 | デフォルト | 説明 |
|---|---|---|---|
| `paymentType` | `TextColumn` | `'expense'` | `PaymentType` の文字列表現 |

定義例（drift DSL）:
```
TextColumn get paymentType =>
    text().withDefault(const Constant('expense'))();
```

## 4-2. database.dart（マイグレーション）

**ファイル:** `flutter/lib/repository/impl/drift/database.dart`

- `schemaVersion` を `8` に変更する
- `onUpgrade` に `from < 8` の分岐を追加する:

```sql
ALTER TABLE payments ADD COLUMN payment_type TEXT NOT NULL DEFAULT 'expense'
```

## 4-3. drift_event_repository.dart（マッパー変更）

**ファイル:** `flutter/lib/repository/impl/drift/repository/drift_event_repository.dart`

- `PaymentData → PaymentDomain` マッパーに `paymentType` フィールドのマッピングを追加する
- `PaymentsCompanion` 生成時に `paymentType` の `Value` を追加する

---

# 5. Adapter 変更

## 5-1. VisitWorkAggregationAdapter（変更）

**ファイル:** `flutter/lib/adapter/visit_work_aggregation_adapter.dart`

現行: `revenue: aggregation.totalPayment`
変更後: `revenue` 種別の PaymentDomain の合計金額を受け取る専用引数に変更する

追加引数:

| 引数名 | 型 | 説明 |
|---|---|---|
| `payments` | `List<PaymentDomain>` | 対象イベントの全 PaymentDomain（論理削除除外済み） |

内部で `payments.where((p) => p.paymentType == PaymentType.revenue)` で絞り込み合計を算出する。

`aggregation.totalPayment` の代わりに `revenueTotal` を `revenue` フィールドに渡す。

## 5-2. PaymentBalanceSectionAdapter（新規）

**ファイル:** `flutter/lib/adapter/payment_balance_section_adapter.dart`

`List<PaymentDomain>` → `PaymentBalanceSectionProjection` への変換を担当する。

変換ロジック:
- `PaymentType.revenue` の PaymentDomain を `revenueItems` リストに変換する
- `PaymentType.expense` の PaymentDomain を `expenseItems` リストに変換する
- 各グループの小計・収支合計を算出する
- メモが未入力の場合は「支払 #N」形式（グループ内の通し番号 N）で代替表示する
- 論理削除済み（`isDeleted == true`）の PaymentDomain は除外する

---

# 6. Projection 変更

## 6-1. PaymentBalanceSectionProjection（新規）

**ファイル:** `flutter/lib/features/overview/projection/payment_balance_section_projection.dart`

visitWork OverView の収支セクション全体を表す表示専用データクラス。

| フィールド名 | 型 | 説明 |
|---|---|---|
| `revenueItems` | `List<PaymentBalanceItemProjection>` | 売上グループの表示アイテム一覧 |
| `expenseItems` | `List<PaymentBalanceItemProjection>` | 支出グループの表示アイテム一覧 |
| `revenueTotalLabel` | `String` | 売上合計の表示文字列（例: `+18,000`） |
| `expenseTotalLabel` | `String` | 支出合計の表示文字列（例: `-3,500`） |
| `balanceTotalLabel` | `String` | 収支合計の表示文字列（例: `+14,500`） |
| `balanceTotalIsPositive` | `bool` | 収支合計が正か（色分け用） |
| `hasItems` | `bool` | 表示すべき項目が1件以上あるか（空時の非表示制御用） |

### PaymentBalanceItemProjection（新規）

各 PaymentDetail 1件分の表示データ。

| フィールド名 | 型 | 説明 |
|---|---|---|
| `paymentId` | `String` | 対応する PaymentDomain の ID |
| `displayMemo` | `String` | メモ or「支払 #N」 |
| `displayAmount` | `String` | 符号付き金額文字列（例: `+15,000`、`-2,000`） |
| `isRevenue` | `bool` | `true` なら売上・`false` なら支出 |

## 6-2. VisitWorkProjection（変更）

**ファイル:** `flutter/lib/features/event_detail/projection/visit_work_projection.dart`

追加フィールド:

| フィールド名 | 型 | 説明 |
|---|---|---|
| `balanceSection` | `PaymentBalanceSectionProjection?` | 収支セクション表示データ。PaymentDomain 0件の場合 null |

---

# 7. BLoC Event 変更

## 7-1. PaymentDetailBloc（変更）

**ファイル:** `flutter/lib/features/payment_detail/bloc/`

### 追加 Event

| Event 名 | 発火タイミング | 説明 |
|---|---|---|
| `PaymentDetailTypeChanged` | ユーザーが「売上 / 支出」セグメント切り替えたとき | Draft の `paymentType` を更新する |

### 既存 Event への影響

- `PaymentDetailStarted`: 既存編集時、Repository から取得した `paymentType` を Draft に反映する
- `PaymentDetailSaveTapped`: `PaymentDomain` 生成時に `paymentType` を含める

## 7-2. EventDetailOverviewBloc（変更）

**ファイル:** `flutter/lib/features/overview/bloc/overview_bloc.dart`

`_runVisitWorkAggregation` において:
- `VisitWorkAggregationAdapter.fromResults` の呼び出しに `payments` 引数（`revenue` 種別絞り込み用）を追加する
- `PaymentBalanceSectionAdapter.toProjection` を呼び出して `PaymentBalanceSectionProjection` を生成する
- `VisitWorkProjection` の `balanceSection` に上記結果を渡す

---

# 8. BLoC State 変更

## 8-1. PaymentDetailDraft（変更）

**ファイル:** `flutter/lib/features/payment_detail/draft/payment_detail_draft.dart`

追加フィールド:

| フィールド名 | 型 | デフォルト | 説明 |
|---|---|---|---|
| `paymentType` | `PaymentType` | `PaymentType.expense` | 選択中の支払種別 |

## 8-2. PaymentDetailLoaded（変更）

State 構造への変更なし。Draft 変更を通じて UI へ伝播する。

---

# 9. View 変更

## 9-1. PaymentDetailPage（変更）

**ファイル:** `flutter/lib/features/payment_detail/view/payment_detail_page.dart`

`_PaymentDetailForm` に「売上 / 支出」セグメントコントロールを追加する。

- 配置: 金額入力フィールド（`paymentDetail_field_amount`）の直上
- UI: `CupertinoSegmentedControl` または `SegmentedButton` で「売上」「支出」の2択
- 選択変更時: `PaymentDetailTypeChanged` イベントを発火する

### Widget キー（新規追加分）

| Key 文字列 | 要素 | 説明 |
|---|---|---|
| `Key('paymentDetail_segment_paymentType')` | セグメントコントロール全体 | 売上/支出の切り替えUI |
| `Key('paymentDetail_segment_revenue')` | 「売上」セグメント | タップで `PaymentType.revenue` に切り替え |
| `Key('paymentDetail_segment_expense')` | 「支出」セグメント | タップで `PaymentType.expense` に切り替え |

## 9-2. VisitWorkOverviewView（変更）

**ファイル:** `flutter/lib/features/overview/view/visit_work_overview_view.dart`

既存の「売上」セクション（`_SectionTitle(title: '売上')` + `_InfoRow` 2行）を、新規 `_PaymentBalanceSection` ウィジェットに置き換える。

`_PaymentBalanceSection` の表示仕様:
- `balanceSection == null` または `hasItems == false` の場合: セクション全体を非表示にする
- 売上グループ（`revenueItems`）:
  - グループタイトル: 「売上」
  - 各アイテム: `displayMemo` + `displayAmount`（緑色）
  - グループ小計: `revenueTotalLabel`（緑色）
- 支出グループ（`expenseItems`）:
  - グループタイトル: 「支出」
  - 各アイテム: `displayMemo` + `displayAmount`（赤色）
  - グループ小計: `expenseTotalLabel`（赤色）
- 収支合計行: `balanceTotalLabel`（正なら緑・負なら赤・0なら標準色）
- 時給換算行: 既存の `revenuePerHourLabel` を収支合計の直下に継続表示（`balanceSection` の `revenue` 合計を元に計算）

### Widget キー（新規追加分）

| Key 文字列 | 要素 | 説明 |
|---|---|---|
| `Key('visitWorkOverview_section_balance')` | 収支セクション全体コンテナ | 空の場合は非表示 |
| `Key('visitWorkOverview_label_revenueTotal')` | 売上合計表示行 | `revenueTotalLabel` 表示 |
| `Key('visitWorkOverview_label_expenseTotal')` | 支出合計表示行 | `expenseTotalLabel` 表示 |
| `Key('visitWorkOverview_label_balanceTotal')` | 収支合計表示行 | `balanceTotalLabel` 表示 |
| `Key('visitWorkOverview_label_revenuePerHour')` | 時給換算表示行 | `revenuePerHourLabel` 表示（null で非表示） |

各アイテム行のキー（`revenueItems`・`expenseItems`）:

| Key 文字列 | 要素 |
|---|---|
| `Key('visitWorkOverview_item_revenue_${paymentId}')` | 売上アイテム行（paymentId で一意） |
| `Key('visitWorkOverview_item_expense_${paymentId}')` | 支出アイテム行（paymentId で一意） |

## 9-3. EventDetailPage タブラベル切り替え（変更）

**ファイル:** `flutter/lib/features/event_detail/view/event_detail_page.dart`

`_TabButton` の `_label` getter を変更する。

現行:
```
EventDetailTab.paymentInfo => '支払'
```

変更後:
- `BlocBuilder<EventDetailBloc, EventDetailState>` で `topicConfig` を取得し、visitWork（`markActions.contains('visit_work_arrive')`）の場合は「収支」、それ以外は「支払」を返す
- `topicConfig` は既存の `EventDetailLoaded.topicConfig` から参照する

### Widget キー（変更なし）

タブボタン自体のキーは既存のまま変更しない。タブラベルの文字列のみ変更される。

---

# 10. Data Flow

## PaymentDetail 登録フロー（追加分）

1. ユーザーが「売上 / 支出」セグメントを切り替える
2. `PaymentDetailTypeChanged(paymentType)` が発火する
3. `PaymentDetailBloc` が Draft の `paymentType` を更新する
4. `PaymentDetailSaveTapped` 発火時に `PaymentDomain` を `paymentType` 込みで生成する
5. `EventRepository.save` でイベント全体を更新する（既存フローと同様）

## OverView 収支集計フロー（変更分）

1. OverView タブ選択 → `OverviewStarted` 発火（既存フロー）
2. `EventDetailOverviewBloc._runVisitWorkAggregation` が呼ばれる
3. `AggregationService.aggregateEvent` で集計（既存）
4. `eventDomain.payments` を `revenue` 種別で絞り込み、合計算出
5. `VisitWorkAggregationAdapter.fromResults` に `payments` を渡して `VisitWorkAggregation` 生成（`revenue` は revenue 種別のみの合計）
6. `PaymentBalanceSectionAdapter.toProjection(eventDomain.payments)` で `PaymentBalanceSectionProjection` 生成
7. `VisitWorkProjection(timeline, aggregation, balanceSection: ...)` 生成
8. `emit(state.copyWith(visitWorkProjection: projection))` でUI更新
9. `VisitWorkOverviewView` が `VisitWorkProjection.balanceSection` を表示する

---

# 11. DB スキーマ変更

| 変更内容 | 詳細 |
|---|---|
| `schemaVersion` | `7 → 8` |
| 追加カラム | `payments.payment_type TEXT NOT NULL DEFAULT 'expense'` |
| 後方互換性 | 既存レコードはすべて `'expense'` として扱われる |
| マイグレーション SQL | `ALTER TABLE payments ADD COLUMN payment_type TEXT NOT NULL DEFAULT 'expense'` |

---

# 12. ファイル変更一覧

## 新規作成

| ファイルパス | 説明 |
|---|---|
| `flutter/lib/domain/transaction/payment/payment_type.dart` | `PaymentType` enum |
| `flutter/lib/adapter/payment_balance_section_adapter.dart` | 収支セクション向け Adapter |
| `flutter/lib/features/overview/projection/payment_balance_section_projection.dart` | 収支セクション Projection |

## 変更

| ファイルパス | 変更内容 |
|---|---|
| `flutter/lib/domain/transaction/payment/payment_domain.dart` | `paymentType` フィールド追加 |
| `flutter/lib/repository/impl/drift/tables/event_tables.dart` | `Payments` テーブルに `paymentType` カラム追加 |
| `flutter/lib/repository/impl/drift/database.dart` | `schemaVersion` 更新・`from < 8` マイグレーション追加 |
| `flutter/lib/repository/impl/drift/repository/drift_event_repository.dart` | `paymentType` のマッピング追加 |
| `flutter/lib/repository/impl/in_memory/seed_data.dart` | `PaymentDomain` 生成箇所に `paymentType` デフォルト値追加 |
| `flutter/lib/adapter/visit_work_aggregation_adapter.dart` | `payments` 引数追加・`revenue` 計算を revenue 種別のみに変更 |
| `flutter/lib/features/event_detail/projection/visit_work_projection.dart` | `balanceSection` フィールド追加 |
| `flutter/lib/features/payment_detail/draft/payment_detail_draft.dart` | `paymentType` フィールド追加 |
| `flutter/lib/features/payment_detail/bloc/payment_detail_event.dart` | `PaymentDetailTypeChanged` 追加 |
| `flutter/lib/features/payment_detail/bloc/payment_detail_bloc.dart` | `_onTypeChanged` ハンドラ追加・保存時 `paymentType` 反映 |
| `flutter/lib/features/payment_detail/view/payment_detail_page.dart` | 売上/支出セグメントコントロール追加 |
| `flutter/lib/features/overview/bloc/overview_bloc.dart` | `_runVisitWorkAggregation` に収支計算追加 |
| `flutter/lib/features/overview/view/visit_work_overview_view.dart` | 収支セクション表示追加 |
| `flutter/lib/features/event_detail/view/event_detail_page.dart` | 支払タブラベル動的切り替え追加 |

---

# 13. テストシナリオ

## テストファイル

`flutter/integration_test/payment_detail_sales_test.dart`

## 前提条件

- iOSシミュレーター（UDID: `DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6`）が起動済みであること
- `--dart-define=FLAVOR=test` でテスト用インメモリ実装を使用すること
- シードデータに visitWork トピックが存在すること（既存シードデータを流用）

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-PDS-001 | 支払詳細フォームに「売上 / 支出」切り替えセグメントが表示される | High |
| TC-PDS-002 | 「売上」を選択して保存すると revenue 種別として登録される | High |
| TC-PDS-003 | 「支出」（デフォルト）を選択して保存すると expense 種別として登録される | High |
| TC-PDS-004 | visitWork OverView に売上グループの項目と合計が表示される | High |
| TC-PDS-005 | visitWork OverView に支出グループの項目と合計が表示される | High |
| TC-PDS-006 | 収支合計（売上合計 - 支出合計）が正しく表示される | High |
| TC-PDS-007 | 時給換算が revenue 種別のみの合計で計算される | High |
| TC-PDS-008 | PaymentDetail が0件の場合、収支セクションが非表示になる | Medium |
| TC-PDS-009 | visitWork の EventDetail 支払タブが「収支」と表示される | High |
| TC-PDS-010 | visitWork 以外（travelExpense）の EventDetail 支払タブが「支払」のまま | High |

---

## シナリオ詳細

### TC-PDS-001: 支払詳細フォームに「売上 / 支出」切り替えセグメントが表示される

**前提:**
- visitWork トピックのイベントが1件存在する

**操作手順:**
1. イベント一覧を表示する
2. visitWork イベントをタップして EventDetail を開く
3. 支払タブ（「収支」）をタップする
4. `+` ボタンをタップして PaymentDetail フォームを開く

**期待結果:**
- `Key('paymentDetail_segment_paymentType')` が表示されている
- `Key('paymentDetail_segment_expense')` が選択状態（デフォルト）になっている

**実装ノート（ウィジェットキー）:**
- `Key('paymentDetail_segment_paymentType')` — セグメントコントロール全体
- `Key('paymentDetail_segment_revenue')` — 「売上」オプション
- `Key('paymentDetail_segment_expense')` — 「支出」オプション

---

### TC-PDS-002: 「売上」を選択して保存すると revenue 種別として登録される

**前提:**
- visitWork トピックのイベントが1件存在する

**操作手順:**
1. EventDetail > 支払タブ > `+` ボタンで PaymentDetail フォームを開く
2. `Key('paymentDetail_segment_revenue')` をタップして「売上」を選択する
3. `Key('paymentDetail_field_amount')` に `15000` を入力する
4. `Key('paymentDetail_button_save')` をタップして保存する
5. EventDetail > 概要タブを開く

**期待結果:**
- 概要タブの `Key('visitWorkOverview_section_balance')` 内に売上グループが表示される
- `Key('visitWorkOverview_label_revenueTotal')` に `+15,000` が表示される

**実装ノート（ウィジェットキー）:**
- `Key('paymentDetail_segment_revenue')`
- `Key('paymentDetail_field_amount')`
- `Key('paymentDetail_button_save')`
- `Key('visitWorkOverview_section_balance')`
- `Key('visitWorkOverview_label_revenueTotal')`

---

### TC-PDS-003: 「支出」（デフォルト）を選択して保存すると expense 種別として登録される

**前提:**
- visitWork トピックのイベントが1件存在する

**操作手順:**
1. PaymentDetail フォームを開く（デフォルト状態＝「支出」選択済み）
2. `Key('paymentDetail_field_amount')` に `2000` を入力する
3. `Key('paymentDetail_button_save')` をタップして保存する
4. EventDetail > 概要タブを開く

**期待結果:**
- `Key('visitWorkOverview_section_balance')` 内に支出グループが表示される
- `Key('visitWorkOverview_label_expenseTotal')` に `-2,000` が表示される

**実装ノート（ウィジェットキー）:**
- `Key('paymentDetail_segment_expense')`
- `Key('visitWorkOverview_label_expenseTotal')`

---

### TC-PDS-004: visitWork OverView に売上グループの項目と合計が表示される

**前提:**
- visitWork トピックのイベントに revenue 種別の PaymentDetail が2件登録済み（金額: 15,000・3,000、メモ: 「案件A」「追加作業」）

**操作手順:**
1. 対象イベントの EventDetail > 概要タブを開く
2. 収支セクションまでスクロールする

**期待結果:**
- `Key('visitWorkOverview_item_revenue_${paymentId1}')` に「案件A」と「+15,000」が表示される
- `Key('visitWorkOverview_item_revenue_${paymentId2}')` に「追加作業」と「+3,000」が表示される
- `Key('visitWorkOverview_label_revenueTotal')` に `+18,000` が表示される

**実装ノート（ウィジェットキー）:**
- `Key('visitWorkOverview_item_revenue_${paymentId}')` — paymentId は動的（各テストで登録直後のIDを使用するか、表示テキストで検索する）
- `Key('visitWorkOverview_label_revenueTotal')`

---

### TC-PDS-005: visitWork OverView に支出グループの項目と合計が表示される

**前提:**
- visitWork トピックのイベントに expense 種別の PaymentDetail が2件登録済み（金額: 2,000・1,500）

**操作手順:**
1. 対象イベントの EventDetail > 概要タブを開く

**期待結果:**
- 支出グループの2件のアイテムが表示される
- `Key('visitWorkOverview_label_expenseTotal')` に `-3,500` が表示される

**実装ノート（ウィジェットキー）:**
- `Key('visitWorkOverview_item_expense_${paymentId}')`
- `Key('visitWorkOverview_label_expenseTotal')`

---

### TC-PDS-006: 収支合計（売上合計 - 支出合計）が正しく表示される

**前提:**
- revenue 種別: 15,000 + 3,000 = 18,000
- expense 種別: 2,000 + 1,500 = 3,500
- 収支合計 = 18,000 - 3,500 = 14,500（正）

**操作手順:**
1. 対象イベントの EventDetail > 概要タブを開く

**期待結果:**
- `Key('visitWorkOverview_label_balanceTotal')` に `+14,500` が表示される

**実装ノート（ウィジェットキー）:**
- `Key('visitWorkOverview_label_balanceTotal')`

---

### TC-PDS-007: 時給換算が revenue 種別のみの合計で計算される

**前提:**
- visitWork イベントに「到着」→「作業開始」→「作業終了」の ActionTimeLog が登録済み（作業時間 3h）
- revenue 種別: 15,000 のみ登録済み
- expense 種別: 5,000 も別途登録済み

**操作手順:**
1. EventDetail > 概要タブを開く

**期待結果:**
- `Key('visitWorkOverview_label_revenuePerHour')` に `¥5,000 / h` が表示される（expense の 5,000 を含まない）

**実装ノート（ウィジェットキー）:**
- `Key('visitWorkOverview_label_revenuePerHour')`

---

### TC-PDS-008: PaymentDetail が0件の場合、収支セクションが非表示になる

**前提:**
- visitWork トピックのイベントに PaymentDetail が1件も登録されていない

**操作手順:**
1. EventDetail > 概要タブを開く

**期待結果:**
- `Key('visitWorkOverview_section_balance')` が表示されていない（`findsNothing`）

**実装ノート（ウィジェットキー）:**
- `Key('visitWorkOverview_section_balance')` — `findsNothing` で確認

---

### TC-PDS-009: visitWork の EventDetail 支払タブが「収支」と表示される

**前提:**
- visitWork トピックのイベントが1件存在する

**操作手順:**
1. visitWork イベントの EventDetail を開く

**期待結果:**
- タブバーに「収支」というテキストが表示される
- `find.text('収支')` が `findsOneWidget` で見つかる

**実装ノート（ウィジェットキー）:**
- タブラベルはテキスト検索（`find.text('収支')`）で確認する
- 既存のタブボタンキーは変更されないため、キー検索との併用は不要

---

### TC-PDS-010: visitWork 以外（travelExpense）の EventDetail 支払タブが「支払」のまま

**前提:**
- travelExpense トピックのイベントが1件存在する

**操作手順:**
1. travelExpense イベントの EventDetail を開く

**期待結果:**
- タブバーに「支払」というテキストが表示される
- `find.text('収支')` が `findsNothing` になる

**実装ノート（ウィジェットキー）:**
- `find.text('支払')` — `findsOneWidget` で確認
- `find.text('収支')` — `findsNothing` で確認

---

# End of Feature Spec
