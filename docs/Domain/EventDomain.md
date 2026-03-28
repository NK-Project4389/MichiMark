# EventDomain

## 概要

イベント（ドライブ記録の1単位）を表すDomain。
MarkLink・Payment・メンバー・交通手段・タグを束ねるAggregateRoot。

---

## フィールド定義

| フィールド名 | Dart型 | NULL許容 | constructor | デフォルト値 | UI名 | 備考 |
|---|---|---|---|---|---|---|
| `id` | `String` | ❌ | `required` | - | - | PK（UUID文字列） |
| `eventName` | `String` | ❌ | `required` | - | イベント名 | 入力必須。Stateでは空欄許可 |
| `trans` | `TransDomain?` | ✅ | optional | `null` | 交通手段 | nullify（削除時null） |
| `members` | `List<MemberDomain>` | ❌ | optional | `const []` | メンバー | nullify |
| `tags` | `List<TagDomain>` | ❌ | optional | `const []` | タグ | nullify |
| `kmPerGas` | `int?` | ✅ | optional | `null` | 燃費 | 単位：0.1km/L（例：155 = 15.5km/L）。永続は10倍値。UI/Stateでは`/10`変換してDouble表示 |
| `pricePerGas` | `int?` | ✅ | optional | `null` | ガソリン単価 | 単位：1円/L。未給油イベントでは未設定可 |
| `payMember` | `MemberDomain?` | ✅ | optional | `null` | ガソリン支払者 | nullify |
| `markLinks` | `List<MarkLinkDomain>` | ❌ | optional | `const []` | - | cascade削除 |
| `payments` | `List<PaymentDomain>` | ❌ | optional | `const []` | - | cascade削除 |
| `isDeleted` | `bool` | ❌ | optional | `false` | - | 論理削除フラグ |
| `createdAt` | `DateTime` | ❌ | `required` | - | - | 初回登録時のみ設定 |
| `updatedAt` | `DateTime` | ❌ | `required` | - | - | 保存時に更新 |

> **永続化のみ:** `schemaVersion`（`int`）は永続スキーマ管理用。Domainクラスには含まない。

---

## 関連Domain

| Domain | 関係 | 削除ルール |
|---|---|---|
| `TransDomain` | `trans: TransDomain?` | nullify |
| `MemberDomain` | `members: List<MemberDomain>` | nullify |
| `TagDomain` | `tags: List<TagDomain>` | nullify |
| `MemberDomain` | `payMember: MemberDomain?` | nullify |
| `MarkLinkDomain` | `markLinks: List<MarkLinkDomain>` | cascade |
| `PaymentDomain` | `payments: List<PaymentDomain>` | cascade |

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
