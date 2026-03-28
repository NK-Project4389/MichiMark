# PaymentDomain

## 概要

イベントに紐づく支払情報を表すDomain。
支払金額・支払メンバー・割り勘メンバーを管理する。

---

## フィールド定義

| フィールド名 | Dart型 | NULL許容 | constructor | デフォルト値 | UI名 | 備考 |
|---|---|---|---|---|---|---|
| `id` | `String` | ❌ | `required` | - | - | PK（UUID文字列） |
| `paymentSeq` | `int` | ❌ | `required` | - | - | 表示順 |
| `paymentAmount` | `int` | ❌ | `required` | - | 支払金額 | 単位：1円（例：1,000円） |
| `paymentMember` | `MemberDomain` | ❌ | `required` | - | 支払メンバー名 | nullify（削除時null） |
| `splitMembers` | `List<MemberDomain>` | ❌ | optional | `const []` | 割り勘メンバー名 | nullify |
| `paymentMemo` | `String?` | ✅ | optional | `null` | 支払メモ | 入力必須。Stateでは空欄許可 |
| `isDeleted` | `bool` | ❌ | optional | `false` | - | 論理削除フラグ |
| `createdAt` | `DateTime` | ❌ | `required` | - | - | 初回登録時のみ設定 |
| `updatedAt` | `DateTime` | ❌ | `required` | - | - | 保存時に更新 |

> **永続化のみ:** `schemaVersion`（`int`）はDomainバージョン管理用。Domainクラスには含まない。

---

## 関連Domain

| Domain | 関係 | 削除ルール |
|---|---|---|
| `MemberDomain` | `paymentMember: MemberDomain` | nullify |
| `MemberDomain` | `splitMembers: List<MemberDomain>` | nullify |

---

## Mapper備考

| フィールド | Mapper |
|---|---|
| `paymentMember` | MemberMapper使用 / nullify |
| `splitMembers` | MemberMapper使用 / nullify |
| その他 | そのまま |

---

## Architecture Notes

- DomainはUIを知らない
- `Equatable` を継承する
- `const` コンストラクタ使用
- IDは `String`（UUID文字列）

---

## ⚠️ Spec整合メモ

PaymentDetail Spec の Draft フィールド名が以下のようにDomainと異なっていた。Specを修正済み。

| Domain | 旧Spec（誤） | 修正後 |
|---|---|---|
| `paymentAmount` | `amount` | `paymentAmount` |
| `paymentMember` | `payer` | `paymentMember` |
| `paymentMemo` | `memo` | `paymentMemo` |
| `splitMembers` | 未記載 | `splitMembers` |
