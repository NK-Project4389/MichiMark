# Feature Spec: FS-moving_cost_balance

- **Spec ID**: FS-moving_cost_balance
- **要件書**: REQ-moving_cost_balance
- **作成日**: 2026-04-13
- **担当**: architect
- **ステータス**: 確定
- **種別**: 機能追加（F-2）

---

# 1. Feature Overview

## Feature Name

MovingCostBalance（移動コスト集計 収支バランス表示）

## Purpose

概要タブの移動コスト集計セクションに「収支バランス」セクションを追加する。

movingCost（給油実績モード）では各MarkLinkのガソリン支払者・参加メンバーから、movingCostEstimated（燃費推定モード）ではイベント全体のガソリン支払者・メンバーから、それぞれガソリン代の収支（立替額 − 負担額）をメンバーごとに算出して表示する。

## Scope

含むもの
- `MovingCostOverviewProjection` への収支バランスフィールド追加
- `MovingCostBalanceAdapter`（新規）: EventDomain から収支バランス Projection を算出するロジック
- `EventDetailOverviewAdapter.toMovingCostProjection` の呼び出し変更（EventDomain を引数に追加）
- `MovingCostOverviewView` に「収支バランス」セクションの追加

含まないもの
- 旅費集計（TravelExpenseOverviewView）への変更
- Bloc・State・Draft・Repository の変更
- 「支払いごとの精算」セクションの移動コスト集計への追加
- movingCost / movingCostEstimated のTopicConfig変更

---

# 2. Feature Responsibility

- Projection生成（Adapter経由）
- Widget表示

RootはこのFeatureの内部状態を変更しない。

---

# 3. Projection Model

## 3-1. 追加フィールド

`MovingCostOverviewProjection` に以下のフィールドを追加する。

| フィールド名 | 型 | 説明 |
|---|---|---|
| `memberBalances` | `List<MemberBalanceProjection>` | メンバー別収支バランス一覧。収支データがない場合は空リスト |

`MemberBalanceProjection` は `TravelExpenseOverviewAdapter` で定義済みの既存クラスを共用する。

```
class MemberBalanceProjection {
  final String memberName;   // メンバー名
  final int balance;         // 支払額 − 負担額（プラス=受け取る側、マイナス=支払う側）
}
```

---

# 4. Adapter

## 4-1. MovingCostBalanceAdapter（新規）

`EventDomain` を受け取り `List<MemberBalanceProjection>` を返す。

### movingCost（給油実績モード）の計算ロジック

対象データ: `isFuel == true` かつ `isDeleted == false` かつ `gasPayer != null` かつ `gasPrice != null` かつ `members` が空でない MarkLink

各MarkLinkで:
1. `gasPayer.memberName` の支払額に `gasPrice` を加算する
2. `members` に含まれる各メンバーの負担額に `gasPrice ~/ members.length` を加算する

収支 = 支払額合計 − 負担額合計

条件を満たすMarkLinkが1件もない場合は空リストを返す。

### movingCostEstimated（燃費推定モード）の計算ロジック

対象データ:
- `EventDomain.payMember`（ガソリン支払者）
- `EventDomain.members`（イベントメンバー）
- 推計ガソリン代 = `totalDistance / (kmPerGas / 10.0) * pricePerGas`（小数点以下切り捨て）

条件チェック（いずれかが欠ける場合は空リストを返す）:
- `payMember` が null でないこと
- `members` が空でないこと
- `kmPerGas` が null かつ 0より大きいこと
- `pricePerGas` が null でないこと
- `totalDistance` が 0より大きいこと

計算:
1. `payMember.memberName` の支払額に推計ガソリン代を加算する
2. `members` に含まれる各メンバーの負担額に `estimatedGasPrice ~/ members.length` を加算する

収支 = 支払額 − 負担額

## 4-2. EventDetailOverviewAdapter の変更

`toMovingCostProjection` メソッドのシグネチャは変更しない（既に `EventDomain? event` を受け取っている）。

`EventDomain` が渡されている場合に `MovingCostBalanceAdapter` を呼び出して収支バランスを計算し、`MovingCostOverviewProjection.memberBalances` に設定する。

`EventDomain` が null の場合は `memberBalances` を空リストとして設定する。

---

# 5. Data Flow

```
EventDomain
  ↓
EventDetailOverviewAdapter.toMovingCostProjection(result, event: event)
  ↓
MovingCostBalanceAdapter.toBalances(event, topicType)
  ↓
List<MemberBalanceProjection>
  ↓
MovingCostOverviewProjection.memberBalances
  ↓
MovingCostOverviewView（収支バランスセクション表示）
```

Bloc・State・Draft は変更しない。`EventDetailOverviewAdapter` は既に `EventDomain` を受け取っているため、Bloc側の変更は不要。

---

# 6. View 変更方針

## 6-1. MovingCostOverviewView への追加

「費用」セクションの直下に「収支バランス」セクションを追加する。

```
距離セクション
費用セクション
収支バランスセクション（projection.memberBalances が空でない場合のみ表示）
```

`_BalanceRow` ウィジェットは `TravelExpenseOverviewView` に定義済みのものを参照せず、`MovingCostOverviewView` 内に同仕様の `_BalanceRow` ウィジェットを別途定義する（ファイルをまたいだプライベートクラス共有はしない）。

---

# 7. TopicType 判定

`MovingCostBalanceAdapter` は TopicConfig の `showLinkDistance` フラグのみで両モードを区別できないため、`EventDomain.topic?.topicType` を使用してモードを判定する。

| topicType | 計算ロジック |
|---|---|
| `movingCost` または null | 給油実績モード（MarkLink単位） |
| `movingCostEstimated` | 燃費推定モード（イベント全体） |

---

# 8. Widget Key 命名規則

| キー | 説明 |
|---|---|
| `Key('movingCostOverview_section_balance')` | 収支バランスセクション全体のコンテナ |
| `Key('movingCostOverview_row_balance_N')` | N番目のメンバーの収支バランス行（インデックス付き） |

---

# 9. Test Scenarios

## 前提条件

- iOSシミュレーターが起動済みであること
- `movingCost` トピックのイベントが少なくとも1件存在すること（MarkLinkにガソリン支払者・参加メンバー・ガソリン代が設定済み）
- `movingCostEstimated` トピックのイベントが少なくとも1件存在すること（燃費・ガソリン単価・ガソリン支払者・メンバーが設定済み）
- 収支データがない（ガソリン支払者未設定）イベントが少なくとも1件存在すること

## テストシナリオ一覧

| ID | シナリオ名 | 優先度 |
|---|---|---|
| TC-MCB-001 | 給油実績モード: 収支バランスセクションが表示される | High |
| TC-MCB-002 | 給油実績モード: ガソリン支払者の収支がプラスで表示される | High |
| TC-MCB-003 | 給油実績モード: 参加メンバーの収支がマイナスで表示される | High |
| TC-MCB-004 | 燃費推定モード: 収支バランスセクションが表示される | High |
| TC-MCB-005 | 燃費推定モード: ガソリン支払者の収支がプラスで表示される | High |
| TC-MCB-006 | 収支データなし: 収支バランスセクションが非表示になる | High |

---

## シナリオ詳細

### TC-MCB-001: 給油実績モード: 収支バランスセクションが表示される

**前提:**
- `movingCost`（給油実績モード）トピックのイベントが存在すること
- MarkLinkに `isFuel == true` かつ `gasPayer` と `gasPrice` が設定済みで `members` が1人以上存在すること

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. 対象イベントをタップして EventDetail を開く
3. 「概要」タブをタップする
4. 画面をスクロールして集計セクションを表示する

**期待結果:**
- `Key('movingCostOverview_section_balance')` のウィジェットが画面上に存在する

**実装ノート（ウィジェットキー一覧）:**

| キー | 説明 |
|---|---|
| `Key('movingCostOverview_section_balance')` | 収支バランスセクション全体 |

---

### TC-MCB-002: 給油実績モード: ガソリン支払者の収支がプラスで表示される

**前提:**
- TC-MCB-001 の状態が達成されていること

**操作手順:**
1. TC-MCB-001 の手順 1〜4 を実行する
2. 収支バランスセクションを確認する

**期待結果:**
- `Key('movingCostOverview_row_balance_0')` のウィジェットが存在する
- ガソリン支払者に対応する行の金額テキストが `+` で始まる文字列を含む

**実装ノート（ウィジェットキー一覧）:**

| キー | 説明 |
|---|---|
| `Key('movingCostOverview_row_balance_0')` | 1番目のメンバーの収支行（インデックス0） |

---

### TC-MCB-003: 給油実績モード: 参加メンバーの収支がマイナスで表示される

**前提:**
- TC-MCB-001 の状態が達成されていること
- ガソリン支払者とは別の参加メンバーが1人以上存在すること

**操作手順:**
1. TC-MCB-001 の手順 1〜4 を実行する
2. 収支バランスセクションを確認する

**期待結果:**
- ガソリン支払者ではない参加メンバーに対応する行の金額テキストが `-` で始まる文字列を含む

**実装ノート（ウィジェットキー一覧）:**

| キー | 説明 |
|---|---|
| `Key('movingCostOverview_row_balance_N')` | N番目のメンバーの収支行（インデックスは表示順） |

---

### TC-MCB-004: 燃費推定モード: 収支バランスセクションが表示される

**前提:**
- `movingCostEstimated`（燃費推定モード）トピックのイベントが存在すること
- `payMember`・`members`（1人以上）・`kmPerGas`・`pricePerGas` がすべて設定済みであること

**操作手順:**
1. アプリを起動してイベント一覧を表示する
2. `movingCostEstimated` トピックのイベントをタップして EventDetail を開く
3. 「概要」タブをタップする
4. 画面をスクロールして集計セクションを表示する

**期待結果:**
- `Key('movingCostOverview_section_balance')` のウィジェットが画面上に存在する

**実装ノート（ウィジェットキー一覧）:**

| キー | 説明 |
|---|---|
| `Key('movingCostOverview_section_balance')` | 収支バランスセクション全体 |

---

### TC-MCB-005: 燃費推定モード: ガソリン支払者の収支がプラスで表示される

**前提:**
- TC-MCB-004 の状態が達成されていること

**操作手順:**
1. TC-MCB-004 の手順 1〜4 を実行する
2. 収支バランスセクションを確認する

**期待結果:**
- `Key('movingCostOverview_row_balance_0')` のウィジェットが存在する
- ガソリン支払者（payMember）に対応する行の金額テキストが `+` で始まる文字列を含む

**実装ノート（ウィジェットキー一覧）:**

| キー | 説明 |
|---|---|
| `Key('movingCostOverview_row_balance_0')` | 1番目のメンバーの収支行 |

---

### TC-MCB-006: 収支データなし: 収支バランスセクションが非表示になる

**前提:**
- `movingCost` または `movingCostEstimated` トピックのイベントが存在すること
- ガソリン支払者（`gasPayer` または `payMember`）が未設定であること、または給油MarkLinkが存在しないこと

**操作手順:**
1. アプリを起動して対象イベントをタップして EventDetail を開く
2. 「概要」タブをタップする
3. 画面をスクロールして集計セクションを確認する

**期待結果:**
- `Key('movingCostOverview_section_balance')` のウィジェットが画面上に存在しない

**実装ノート（ウィジェットキー一覧）:**

| キー | 説明 |
|---|---|
| `Key('movingCostOverview_section_balance')` | 収支バランスセクション全体（非表示確認用） |

---

# End of Feature Spec
