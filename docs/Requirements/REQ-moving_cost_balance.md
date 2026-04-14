# 要件書: 移動コスト集計 収支バランス追加

- **要件ID**: REQ-moving_cost_balance
- **作成日**: 2026-04-13
- **担当**: product-manager
- **ステータス**: 確定
- **種別**: 機能追加（F-2）

---

## 1. 背景・目的

EventDetail 概要タブの旅費集計（travelExpense）には「収支バランス」セクションが存在し、メンバーごとの立替額・負担額の差分が一目でわかる。

一方、移動コスト集計（movingCost・movingCostEstimated）には「距離」「費用」のみが表示されており、ガソリン代の収支バランスを確認できない。

給油実績モード（movingCost）では各MarkLink/LinkDetailにガソリン支払者と参加メンバーが記録されており、燃費推定モード（movingCostEstimated）ではイベント全体のガソリン支払者とイベントメンバーが記録されている。これらを使って旅費集計と同様の収支バランス表示を実現する。

---

## 2. 機能要件

### 2-1. 表示対象

概要タブの移動コスト集計セクション（`MovingCostOverviewView`）に「収支バランス」セクションを追加する。

対象トピックタイプ:
- `movingCost`（給油実績モード）
- `movingCostEstimated`（燃費推定モード）

### 2-2. 表示内容

「収支バランス」セクションを費用セクションの直下に追加する。

表示する行:
- メンバー名（左）
- 収支金額（右）: `+N円`（プラス=受け取る側・緑色）または `-N円`（マイナス=支払う側・赤色）

収支が0円のメンバーは表示する（0円と明示する）。

ガソリン支払者・参加メンバーが存在しない場合（収支データなし）はセクション自体を非表示にする。

### 2-3. 収支バランスの計算ロジック

#### movingCost（給油実績モード）

MarkLink単位でガソリン代の立替・負担を計算する。

```
各MarkLink（isFuel == true かつ isDeleted == false）:
  支払者 = gasPayer（存在する場合）
  金額 = gasPrice
  負担メンバー = members（存在する場合、均等割り）

収支 = 支払額合計 − 負担額合計
  ※ gasPayerがnullのMarkLinkは収支計算から除外
  ※ membersが空のMarkLinkは収支計算から除外
```

#### movingCostEstimated（燃費推定モード）

イベント全体のガソリン代推計値を1人の支払者が立て替え、イベントメンバー全員で均等負担する。

```
支払者 = EventDomain.payMember
推計ガソリン代 = totalDistance / (kmPerGas / 10.0) * pricePerGas（小数点以下切り捨て）
負担メンバー = EventDomain.members（均等割り）

収支 = 支払額 − 負担額
  ※ payMemberがnullの場合は収支セクションを非表示
  ※ members が空の場合は収支セクションを非表示
  ※ 推計ガソリン代が算出不可（kmPerGas・pricePerGas が null）の場合は収支セクションを非表示
```

### 2-4. 表示フォーマット

旅費集計（`TravelExpenseOverviewView`）の収支バランス行（`_BalanceRow`）と同一のフォーマットを適用する。

| 要素 | 表示仕様 |
|---|---|
| セクションタイトル | 「収支バランス」・`titleSmall`・プライマリカラー |
| 金額（プラス） | `+N円` 形式・緑色・Bold |
| 金額（マイナス） | `-N円` 形式・赤色（エラーカラー）・Bold |
| 金額（ゼロ） | `0円` または `+0円` 形式 |

---

## 3. 非機能要件

- 既存の「距離」「費用」セクションのレイアウトは変更しない
- Adapter（計算ロジック）は既存の `EventDetailOverviewAdapter` または新規 Adapter として実装し、View（Widget）に計算ロジックを持たせない
- 旅費集計の収支バランス表示（`MemberBalanceProjection` / `_BalanceRow`）のコードと整合性を保つこと

---

## 4. 対象外

- 旅費集計（travelExpense）への変更
- 「支払いごとの精算」セクションの移動コスト集計への追加
- 支払人が複数いる場合の最適精算計算（最少精算回数アルゴリズム）

---

## 5. 承認

- 承認日: 2026-04-13
