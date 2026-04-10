# 要件書: 燃費更新機能

- **要件ID**: REQ-fuel_efficiency_update
- **作成日**: 2026-04-10
- **担当**: product-manager
- **ステータス**: 確定
- **関連タスク**: T-120〜T-124

---

## 背景・目的

`movingCostEstimated`（燃費推定モード）の概要タブでは、燃費（km/L）を手動で入力できる。
しかし交通手段マスター（`TransDomain.kmPerGas`）には車両ごとの燃費が登録されており、
交通手段を選択したときにマスターの燃費値が自動で反映されないため、毎回手動入力が必要になっている。

本要件は「概要タブで交通手段を選択したとき、マスターの燃費（`kmPerGas`）で概要タブの燃費入力欄を上書きする」機能を定義する。

---

## UXフロー

1. `movingCostEstimated` イベントの概要タブを開く
2. 交通手段の選択行をタップして交通手段マスターを選択する
3. 選択完了時、選択した交通手段の `kmPerGas` で燃費入力欄（`kmPerGasInput`）を**上書き**する
4. マスターの `kmPerGas` が null の場合は燃費入力欄を変更しない

---

## 要件一覧

| ID | 要件 | 優先度 |
|---|---|---|
| REQ-FEU-001 | 交通手段選択時、選択した Trans の `kmPerGas` が non-null であれば概要タブの燃費入力欄を上書きする | Must |
| REQ-FEU-002 | 選択した Trans の `kmPerGas` が null の場合は燃費入力欄を変更しない | Must |
| REQ-FEU-003 | 上書きは `movingCostEstimated` TopicType のみ行う。他の TopicType では燃費入力欄が非表示のため対象外 | Must |
| REQ-FEU-004 | 上書き後、ユーザーは燃費入力欄を手動で変更できる（通常の編集フロー） | Must |

---

## 燃費値の変換仕様

`TransDomain.kmPerGas`（int、0.1km/L単位）→ `BasicInfoDraft.kmPerGasInput`（小数文字列）の変換：

| 変換 | 計算式 | 例 |
|---|---|---|
| マスター → 入力欄 | `(kmPerGas / 10.0).toStringAsFixed(1)` | `155` → `"15.5"` |

---

## 実装方針

`BasicInfoBloc` の `BasicInfoTransSelected` ハンドラーにて、
選択された `TransDomain.kmPerGas` が non-null かつ TopicType が `movingCostEstimated` の場合に、
`draft.kmPerGasInput` を変換値で更新する。

---

## スコープ外

- 概要タブの燃費変更を交通手段マスターに書き戻す機能
- `pricePerGas`（ガソリン単価）の自動反映
- `meterValue`（累積メーター初期値）の自動反映
- `movingCost`（給油実績モード）への適用

---

## 参照

- タスクボード: T-120〜T-124
