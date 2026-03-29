# FuelDetail 要件書

## 背景・目的

MichiMarkでは Mark（地点）および Link（移動区間）に給油情報（isFuel, pricePerGas, gasQuantity, gasPrice）を記録できる。
しかし「単価・給油量・合計金額」の3つの値は互いに依存関係があり、ユーザーが2つを入力すれば残り1つを自動計算できる。

FuelDetailは、この計算を補助するインラインFeatureとして、MarkDetail / LinkDetail 画面内に組み込む。

---

## ユーザーストーリー

- ユーザーとして、ガソリン単価と給油量を入力したとき、合計金額を自動計算したい
- ユーザーとして、ガソリン単価と合計金額を入力したとき、給油量を自動計算したい
- ユーザーとして、入力値をすべてクリアして入力をやり直したい

---

## 機能要件

### 入力フィールド

| フィールド | UI表示名 | 型（UI/Draft） | 型（Domain） | 単位 | 備考 |
|---|---|---|---|---|---|
| `pricePerGas` | ガソリン単価 | `String` | `int?` | 円/L | 必須入力。計算の対象外（単価は計算しない） |
| `gasQuantity` | 給油量 | `String` | `double?` | L | 小数点1桁（例：30.0） |
| `gasPrice` | ガソリン代（合計） | `String` | `int?` | 円 | 整数 |

### 計算ロジック

- **計算実行条件：** 単価（pricePerGas）が入力済み、かつ gasQuantity / gasPrice のうち **1つだけ** が未入力
- **計算方向：**

| 入力済み | 計算される値 | 計算式 |
|---|---|---|
| 単価 + 給油量 | 合計 = 単価 × 給油量 | `gasPrice = pricePerGas × gasQuantity` |
| 単価 + 合計 | 給油量 = 合計 ÷ 単価 | `gasQuantity = gasPrice / pricePerGas`（小数点1桁） |

- 単価は計算の対象外（常にユーザー入力）
- 条件を満たさない場合は Calculate を押しても何もしない

### 操作

| 操作 | 内容 |
|---|---|
| Calculate ボタン | 上記計算ロジックを実行し、未入力フィールドを更新する |
| Clear ボタン | pricePerGas / gasQuantity / gasPrice をすべて空欄にリセットする |

---

## 非機能要件

- FuelDetailは **Domain を持たない**（永続化はMarkDetail / LinkDetailが担当）
- MarkDetail / LinkDetail 画面に **インライン埋め込み** で表示する（別画面へのナビゲーションなし）
- 計算結果はMarkDetail / LinkDetailのDraftに直接反映される

---

## スコープ外

- 単価の自動計算（単価はユーザーが常に入力する）
- 給油履歴の集計・グラフ表示
- 単位変換（L ↔ ガロンなど）

---

## 受け入れ条件

- [ ] 単価 + 給油量 入力後にCalculateを押すと合計が計算される
- [ ] 単価 + 合計 入力後にCalculateを押すと給油量が計算される（小数点1桁）
- [ ] 3つすべて入力済みの状態でCalculateを押しても何も起きない
- [ ] 単価が未入力の状態でCalculateを押しても何も起きない
- [ ] Clearを押すと3つのフィールドがすべて空になる
- [ ] FuelDetail の状態変化が MarkDetail / LinkDetail の Draft に正しく反映される

---

## 備考

- SwiftUI版（FuelDetailReducer.swift）では単価必須・2方向計算のみだったが、本要件はFlutter移行にあたって仕様を整理・確定したもの
- `gasQuantity` のDomain保存値は10倍整数（例：30.0L → 300）。Draft/UI層では `double` として扱う
- `MarkLinkDomain.isFuel` フラグとの連携はMarkDetail / LinkDetail側で管理する
