# TransDomain

## 概要

交通手段（乗り物）のマスタDomain。
燃費・メーター値を保持し、EventDomainに紐づく。

---

## フィールド定義

| フィールド名 | Dart型 | NULL許容 | constructor | デフォルト値 | UI名 | 備考 |
|---|---|---|---|---|---|---|
| `id` | `String` | ❌ | `required` | - | - | PK（UUID文字列） |
| `transName` | `String` | ❌ | `required` | - | 交通手段名 | |
| `kmPerGas` | `int?` | ✅ | optional | `null` | 燃費 | 単位：0.1km/L（例：125 = 12.5km/L）。永続は10倍値。UI/Stateでは`/10`変換してDouble表示。Stateでは空欄許可 |
| `meterValue` | `int?` | ✅ | optional | `null` | メーター | 単位：1km。車両ごとの累積値。Stateでは空欄許可 |
| `isVisible` | `bool` | ❌ | optional | `true` | 表示設定 | `false` で選択画面から非表示 |
| `isDeleted` | `bool` | ❌ | optional | `false` | - | 論理削除フラグ |
| `createdAt` | `DateTime` | ❌ | `required` | - | - | 初回登録時のみ設定 |
| `updatedAt` | `DateTime` | ❌ | `required` | - | - | 保存時に更新 |

> **永続化のみ:** `schemaVersion`（`int`）はDomainバージョン管理用。Domainクラスには含まない。

---

## 型変換ルール

| フィールド | 永続値 | Domain/UI値 | 変換 |
|---|---|---|---|
| `kmPerGas` | `int`（10倍値） | `double`（UI表示） | 永続→Domain: `/10`、Domain→永続: `×10` |

---

## Architecture Notes

- DomainはUIを知らない
- `Equatable` を継承する
- `const` コンストラクタ使用
- IDは `String`（UUID文字列）
