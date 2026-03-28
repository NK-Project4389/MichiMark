# MemberDomain

## 概要

イベント参加者のマスタDomain。
EventDomain・MarkLinkDomain・PaymentDomainで参照される。

---

## フィールド定義

| フィールド名 | Dart型 | NULL許容 | constructor | デフォルト値 | UI名 | 備考 |
|---|---|---|---|---|---|---|
| `id` | `String` | ❌ | `required` | - | - | PK（UUID文字列） |
| `memberName` | `String` | ❌ | `required` | - | メンバー名 | |
| `mailAddress` | `String?` | ✅ | optional | `null` | メールアドレス | 将来の共有・招待・通知用途を想定（**現時点では未使用**） |
| `isVisible` | `bool` | ❌ | optional | `true` | 表示設定 | `false` で選択画面から非表示 |
| `isDeleted` | `bool` | ❌ | optional | `false` | - | 論理削除フラグ |
| `createdAt` | `DateTime` | ❌ | `required` | - | - | 初回登録時のみ設定 |
| `updatedAt` | `DateTime` | ❌ | `required` | - | - | 保存時に更新 |

> **永続化のみ:** `schemaVersion`（`int`）はDomainバージョン管理用。Domainクラスには含まない。

---

## Architecture Notes

- DomainはUIを知らない
- `Equatable` を継承する
- `const` コンストラクタ使用
- IDは `String`（UUID文字列）
- `mailAddress` は将来拡張フィールド。現時点ではUI・ロジックで使用しない
