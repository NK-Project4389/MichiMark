# Feature Spec: PaymentInfo UI 改善 + 支払いごとの精算セクション追加

**Spec ID**: PaymentInfoRedesign_Spec
**要件書**: `docs/Requirements/REQ-payment_info_redesign.md`
**作成日**: 2026-04-09
**ステータス**: Draft

---

## 1. Feature Overview

### Feature Name

PaymentInfoRedesign（PaymentInfoFeature の UI 改善 + 概要タブ精算セクション追加）

### Purpose

1. PaymentInfo タブの `_PaymentListTile` を視認性の高い多行レイアウトに刷新する
2. 概要タブ（`TravelExpenseOverviewView`）の「収支バランス」セクション直下に「支払いごとの精算」セクションを追加する

### Scope

含むもの

- `_PaymentListTile` のレイアウト変更（多行・チップ表示）
- `PerPaymentSettlementProjection` / `SettlementLineProjection` の新規定義
- `PerPaymentSettlementAdapter` の新規定義（Adapter 層）
- `TravelExpenseOverviewProjection` への `perPaymentSettlements` フィールド追加
- `TravelExpenseOverviewAdapter.toProjection` の拡張
- `TravelExpenseOverviewView` への「支払いごとの精算」セクション追加

含まないもの

- PaymentInfoBloc / PaymentInfoState / PaymentInfoEvent の変更
- 精算の最適化（最小送金数アルゴリズム）
- 表示フォーマット統一（円 vs 円 の表記揺れ解消は別タスク）
- Overview タブ以外への精算セクション追加

---

## 2. 変更対象レイヤー

| ファイル | 変更種別 | 主な変更内容 |
|---|---|---|
| `payment_info/view/payment_info_view.dart` | 変更 | `_PaymentListTile` を多行・チップレイアウトに変更 |
| `adapter/travel_expense_overview_adapter.dart` | 変更 | `PerPaymentSettlementProjection` / `SettlementLineProjection` 追加、`TravelExpenseOverviewProjection` に `perPaymentSettlements` 追加、`TravelExpenseOverviewAdapter.toProjection` に精算計算を追加 |
| `overview/view/travel_expense_overview_view.dart` | 変更 | 「支払いごとの精算」セクション追加 |

---

## 3. Projection 変更定義

### 3-1. 新規: SettlementLineProjection

単一の精算行（支払う人 → 受け取る人: 金額）を表す表示専用モデル。

| フィールド | 型 | 説明 |
|---|---|---|
| `payerName` | String | 支払う人の名前（支払者に返す側） |
| `receiverName` | String | 受け取る人の名前（立て替えた支払者） |
| `displayAmount` | String | 精算金額の表示文字列（例: "¥1,750"） |

### 3-2. 新規: PerPaymentSettlementProjection

伝票 1 件分の精算カードを表す表示専用モデル。

| フィールド | 型 | 説明 |
|---|---|---|
| `displayTitle` | String | メモが空の場合 "支払 #N"（N は 1-indexed の伝票番号）、あるいはメモ文字列 |
| `displayAmount` | String | 伝票金額の表示文字列（例: "¥3,500"） |
| `lines` | List\<SettlementLineProjection\> | 精算行一覧。空の場合はカードを非表示とする |

### 3-3. 既存変更: TravelExpenseOverviewProjection

既存フィールドはすべて維持し、以下を追加する。

| フィールド | 型 | 説明 |
|---|---|---|
| `perPaymentSettlements` | List\<PerPaymentSettlementProjection\> | 伝票ごとの精算リスト。割り勘メンバーが 0 件の伝票は除外済み |

---

## 4. Adapter 変更定義

### 4-1. PerPaymentSettlementAdapter（新規）

`adapter/travel_expense_overview_adapter.dart` 内に追加する（同ファイル内の関連ロジックと一体管理）。

**責務**: `List<PaymentDomain>` を受け取り `List<PerPaymentSettlementProjection>` を返す。

**変換ロジック（設計レベル）:**

1. `isDeleted == false` の Payment のみ対象とする
2. `paymentSeq` 昇順でソートする
3. 各 Payment を以下のルールで変換する:
   - `displayTitle`: `memo` が空または null の場合は `"支払 #N"`（N = 1始まりのインデックス）、それ以外は `memo`
   - `displayAmount`: `paymentAmount` を `"¥{#,###}"` 形式にフォーマット
   - `lines`: `splitMembers.isEmpty` の場合は空リストとし、以下を計算する:
     - 均等割り金額 = `paymentAmount ~/ splitMembers.length`（端数切り捨て）
     - 各 `splitMember` に対して `SettlementLineProjection(payerName: splitMember.memberName, receiverName: paymentMember.memberName, displayAmount: "¥{#,###}")` を生成する
4. `lines.isEmpty` の伝票は結果リストから除外する

**アーキテクチャ判断**: 精算計算は純粋な表示変換処理（UI概念・副作用なし）であり、既存の均等割りロジックが Adapter 層に集約されているため、Adapter 層（`travel_expense_overview_adapter.dart`）に実装する。Domain（PaymentDomain）は精算という表示概念を知るべきでない。Projection は計算ロジックを持たない。

### 4-2. TravelExpenseOverviewAdapter.toProjection の変更

既存の `memberCosts` / `memberBalances` 計算ロジックは変更しない。`PerPaymentSettlementAdapter` を呼び出して得た結果を `perPaymentSettlements` フィールドとして `TravelExpenseOverviewProjection` に追加する。

---

## 5. Widget 変更定義

### 5-1. _PaymentListTile の多行レイアウト

既存の 1 行 `ListTile` を以下の多行構成に変更する。

**行構成:**

| 行 | 内容 | 表示条件 |
|---|---|---|
| 行1 | 金額テキスト（`displayAmount`） | 常に表示 |
| 行2 | "支払" ラベル + 支払者チップ（Teal 背景） | 常に表示 |
| 行3 | "割り勘" ラベル + 割り勘メンバーチップ群（Emerald 背景・Wrap 折り返し） | `splitMembers.isNotEmpty` のときのみ |
| 行4 | メモテキスト | `memo != null && memo.isNotEmpty` のときのみ |

**カラー定義:**

| 要素 | カラー |
|---|---|
| 支払者チップ背景 | `Color(0xFF2B7A9B)`（Teal） |
| 割り勘メンバーチップ背景 | `Color(0xFF2E9E6B)`（Emerald） |
| チップテキスト | 白 |
| メモテキスト | `colorScheme.onSurfaceVariant`（secondary） |

**テキストスタイル:**

| 要素 | スタイル |
|---|---|
| 行1 金額 | `titleMedium` または `bodyLarge`・`FontWeight.bold` |
| "支払" / "割り勘" ラベル | `bodySmall` |
| チップ内テキスト | `bodySmall`・白 |
| メモ | `bodySmall`・italic |

**leading**: `Icons.payment` アイコン（変更なし）

**onTap**: `PaymentInfoBloc` に `PaymentInfoPaymentTapped(item.id)` を add（変更なし）

### 5-2. TravelExpenseOverviewView の「支払いごとの精算」セクション追加

`TravelExpenseOverviewView` の「収支バランス」セクション直下に追加する。

**表示ルール**: `projection.perPaymentSettlements.isEmpty` の場合はセクション全体を非表示。

**UI 構成:**

- セクションタイトル: 「支払いごとの精算」・`titleSmall`・`colorScheme.primary`（既存 `_SectionTitle` Widget を流用）
- 各伝票カード:
  - カード間余白: `8px`
  - カード内ヘッダー行: タイトル（左・`bodyMedium`） + 金額（右・`bodyMedium`・Teal 背景 tint）
  - 各精算行: `"{payerName}" → "{receiverName}" : "{displayAmount}"` 形式
    - `payerName` テキスト: `colorScheme.error`（赤）
    - `receiverName` テキスト: `Colors.green.shade700`（緑）
    - `": {displayAmount}"` テキスト: デフォルト

---

## 6. 変更しないもの

- `PaymentInfoBloc` / `PaymentInfoState` / `PaymentInfoEvent`
- `PaymentItemProjection`（既存フィールド構成を維持）
- `PaymentInfoProjection`
- `OverviewBloc` / `OverviewState` / `OverviewEvent`
- OverviewBloc が `TravelExpenseOverviewAdapter.toProjection` を呼ぶ箇所（インターフェース変化なし）

---

## 7. Data Flow

### PaymentListTile 表示フロー

```
PaymentInfoBloc が PaymentInfoLoaded を emit
  → _PaymentInfoList が PaymentItemProjection のリストを受け取る
  → _PaymentListTile が多行レイアウトで表示する
    （payer チップ: Teal / splitMembers チップ: Emerald / memo: italic）
```

### 精算セクション表示フロー

```
OverviewBloc が OverviewStarted を受け取る
  → TravelExpenseOverviewAdapter.toProjection(eventDomain) を呼ぶ
    → PerPaymentSettlementAdapter が PaymentDomain[] を変換する
      → 均等割り計算 → PerPaymentSettlementProjection[] 生成
    → TravelExpenseOverviewProjection(perPaymentSettlements: ...) 生成
  → OverviewBloc が TravelExpenseOverviewLoaded(projection) を emit
  → TravelExpenseOverviewView が「支払いごとの精算」セクションを描画する
```

---

## 8. 既存アーキテクチャへの影響

| 懸念 | 影響 |
|---|---|
| `TravelExpenseOverviewProjection` のフィールド追加 | `TravelExpenseOverviewAdapter.toProjection` と `TravelExpenseOverviewView` のみが参照するため、他 Feature への影響なし |
| `PaymentItemProjection` は変更しない | `_PaymentListTile` は既存フィールド（`payer` / `splitMembers` / `memo` / `displayAmount`）をそのまま利用するため、Projection の変更不要 |
| OverviewBloc の変更なし | `TravelExpenseOverviewAdapter` のシグネチャ（`toProjection(EventDomain)`）は変更しないため、Bloc の修正不要 |

---

## 9. Test Scenarios

### 前提条件

- iOS シミュレーターが起動済みであること
- travelExpense トピックのイベントが 1 件存在すること
- 当該イベントに以下のデータが存在すること:
  - 支払が 2 件以上（うち 1 件以上は割り勘メンバーあり、1 件は割り勘メンバーなし）
  - 各支払に異なる支払者・割り勘メンバーを設定済み

### テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-PIR-001 | PaymentListTile に金額が Bold で表示される | High |
| TC-PIR-002 | PaymentListTile に支払者名が Teal チップで表示される | High |
| TC-PIR-003 | 割り勘メンバーがいる支払に Emerald チップが表示される | High |
| TC-PIR-004 | 割り勘メンバーがいない支払に「割り勘」行が表示されない | High |
| TC-PIR-005 | メモが空の支払にメモ行が表示されない | High |
| TC-PIR-006 | メモが入力済みの支払にメモ行が表示される | Medium |
| TC-PIR-007 | 概要タブに「支払いごとの精算」セクションが表示される | High |
| TC-PIR-008 | 精算セクションに伝票タイトルと金額が表示される | High |
| TC-PIR-009 | 割り勘メンバーがいない伝票が精算セクションに表示されない | High |
| TC-PIR-010 | メモが空の伝票が「支払 #N」タイトルで表示される | Medium |
| TC-PIR-011 | 精算行の支払う人名が赤色で表示される | Medium |
| TC-PIR-012 | 精算行の受け取る人名が緑色で表示される | Medium |
| TC-PIR-013 | 精算金額が均等割り（端数切り捨て）で計算される | High |
| TC-PIR-014 | 精算セクションは「収支バランス」の直下に配置される | Medium |

### シナリオ詳細

#### TC-PIR-001: PaymentListTile に金額が Bold で表示される

**操作手順:**
1. EventDetail を開く
2. 「支払」タブをタップする

**期待結果:**
- 支払リストの各アイテムに金額テキストが表示される
- 金額テキストが `Bold` スタイルで表示される

---

#### TC-PIR-002: PaymentListTile に支払者名が Teal チップで表示される

**操作手順:**
1. 「支払」タブを表示する

**期待結果:**
- 各アイテムに "支払" ラベルが表示される
- 支払者名がチップ形式（Teal 背景・白テキスト）で表示される

---

#### TC-PIR-003: 割り勘メンバーがいる支払に Emerald チップが表示される

**操作手順:**
1. 「支払」タブを表示する
2. 割り勘メンバーが 1 名以上設定された支払アイテムを確認する

**期待結果:**
- "割り勘" ラベルが表示される
- 割り勘メンバー名が Emerald 背景・白テキストのチップで表示される
- 複数メンバーがいる場合はチップが折り返して表示される（Wrap）

---

#### TC-PIR-004: 割り勘メンバーがいない支払に「割り勘」行が表示されない

**操作手順:**
1. 「支払」タブを表示する
2. 割り勘メンバーが 0 名の支払アイテムを確認する

**期待結果:**
- 当該アイテムに "割り勘" ラベルが表示されない
- 当該アイテムに Emerald チップが表示されない

---

#### TC-PIR-005: メモが空の支払にメモ行が表示されない

**操作手順:**
1. メモが空の支払が存在する「支払」タブを表示する

**期待結果:**
- 当該アイテムにメモテキスト行が表示されない

---

#### TC-PIR-006: メモが入力済みの支払にメモ行が表示される

**操作手順:**
1. メモが設定された支払が存在する「支払」タブを表示する

**期待結果:**
- 当該アイテムにメモテキストが italic スタイルで表示される

---

#### TC-PIR-007: 概要タブに「支払いごとの精算」セクションが表示される

**操作手順:**
1. 割り勘メンバーが設定された支払を持つイベントの EventDetail を開く
2. 「概要」タブを表示する

**期待結果:**
- 「支払いごとの精算」セクションタイトルが表示される

---

#### TC-PIR-008: 精算セクションに伝票タイトルと金額が表示される

**操作手順:**
1. TC-PIR-007 の続き

**期待結果:**
- 各伝票のカードにタイトル（または "支払 #N"）と金額が表示される

---

#### TC-PIR-009: 割り勘メンバーがいない伝票が精算セクションに表示されない

**操作手順:**
1. 割り勘メンバーが 0 名の支払と、1 名以上の支払が混在するイベントの概要タブを表示する

**期待結果:**
- 割り勘なしの支払は精算セクションに表示されない
- 割り勘ありの支払のみ精算セクションに表示される

---

#### TC-PIR-010: メモが空の伝票が「支払 #N」タイトルで表示される

**操作手順:**
1. メモなしの支払（割り勘メンバーあり）が存在するイベントの概要タブを表示する

**期待結果:**
- 精算セクションの該当カードのタイトルが「支払 #1」（または相当する番号）で表示される

---

#### TC-PIR-011: 精算行の支払う人名が赤色で表示される

**操作手順:**
1. 精算セクションが表示されたイベントの概要タブを確認する

**期待結果:**
- 各精算行の "→" の左側（支払う人名）が赤色テキストで表示される

---

#### TC-PIR-012: 精算行の受け取る人名が緑色で表示される

**操作手順:**
1. TC-PIR-011 と同じ

**期待結果:**
- 各精算行の "→" の右側（受け取る人名）が緑色テキストで表示される

---

#### TC-PIR-013: 精算金額が均等割り（端数切り捨て）で計算される

**操作手順:**
1. 金額 1,000円・割り勘メンバー 3 名の支払が存在するイベントの概要タブを表示する

**期待結果:**
- 精算セクションの該当カードに 3 件の精算行が表示される
- 各精算行の金額が ¥333（= 1000 ÷ 3 の切り捨て）で表示される

---

#### TC-PIR-014: 精算セクションは「収支バランス」の直下に配置される

**操作手順:**
1. 精算セクションが表示されるイベントの概要タブを表示する
2. 画面をスクロールして「収支バランス」セクションと「支払いごとの精算」セクションの位置関係を確認する

**期待結果:**
- 「収支バランス」セクションの直下に「支払いごとの精算」セクションが配置されている

---

## End of Spec
