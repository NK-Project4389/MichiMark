# MarkLinkDomain

## 概要

Mark（地点）とLink（移動区間）を統合したDomain。
`markLinkType` でMark/Linkを区別する。

---

## フィールド定義

| フィールド名 | Dart型 | NULL許容 | constructor | デフォルト値 | UI名 | 備考 |
|---|---|---|---|---|---|---|
| `id` | `String` | ❌ | `required` | - | - | PK（UUID文字列） |
| `markLinkSeq` | `int` | ❌ | `required` | - | - | 表示順（時系列順） |
| `markLinkType` | `MarkOrLink` | ❌ | optional | `MarkOrLink.mark` | - | `mark` / `link` |
| `markLinkDate` | `DateTime` | ❌ | `required` | - | イベント日 | 任意の日付に設定可能 |
| `markLinkName` | `String?` | ✅ | optional | `null` | マーク名 / リンク名 | 入力必須。Stateでは空欄許可 |
| `members` | `List<MemberDomain>` | ❌ | optional | `const []` | メンバー | 参加メンバー一覧 |
| `meterValue` | `int?` | ✅ | optional | `null` | メーター | 単位：1km。累積値。**Markのみ有効**（Linkでは`null`） |
| `distanceValue` | `int?` | ✅ | optional | `null` | 走行距離 | 単位：1km。区間差分。**Linkのみ有効**（Markでは`null`） |
| `actions` | `List<ActionDomain>` | ❌ | optional | `const []` | 行動 | 行動リスト |
| `memo` | `String?` | ✅ | optional | `null` | メモ | 入力必須。Stateでは空欄許可 |
| `isFuel` | `bool` | ❌ | optional | `false` | 給油フラグ | `false` の場合、給油関連フィールドはすべて`null` |
| `pricePerGas` | `int?` | ✅ | optional | `null` | ガソリン単価 | 単位：1円/L。`isFuel == true` のときのみ有効 |
| `gasQuantity` | `int?` | ✅ | optional | `null` | 給油量 | 単位：0.1L（例：300 = 30.0L）。永続は10倍値。UI/Stateでは`/10`変換 |
| `gasPrice` | `int?` | ✅ | optional | `null` | ガソリン代 | 単位：1円。`isFuel == true` のときのみ有効 |
| `isDeleted` | `bool` | ❌ | optional | `false` | - | 論理削除フラグ |
| `createdAt` | `DateTime` | ❌ | `required` | - | - | 初回登録時のみ設定 |
| `updatedAt` | `DateTime` | ❌ | `required` | - | - | 保存時に更新 |

> **永続化のみ:** `schemaVersion`（`int`）はDomainバージョン管理用。Domainクラスには含まない。

---

## MarkOrLink enum

```dart
/// マーク（地点）またはリンク（経路）を表す区分
enum MarkOrLink { mark, link }
```

---

## 排他ルール（MarkLinkType別）

| Type | 有効フィールド | 無効フィールド |
|---|---|---|
| `mark` | `meterValue` | `distanceValue`（`null`） |
| `link` | `distanceValue` | `meterValue`（`null`） |

---

## 関連Domain

| Domain | 関係 | 削除ルール |
|---|---|---|
| `MemberDomain` | `members: List<MemberDomain>` | nullify |
| `ActionDomain` | `actions: List<ActionDomain>` | nullify |

---

## 型変換ルール

| フィールド | 永続値 | Domain/UI値 | 変換 |
|---|---|---|---|
| `gasQuantity` | `int`（10倍値） | `double`（UI表示） | 永続→Domain: `/10`、Domain→永続: `×10` |

---

## 距離採用優先順位ルール

Linkの「採用距離」は以下の優先順位で決定する。

1. **meter差分**（前後MarkのmeterValue差分が妥当な場合）
2. **distanceValue**（ユーザー入力 / 実測値）

> この計算はMarkLinkDomain自体ではなく、上位のAdapter/集計層で行う。

---

## Architecture Notes

- DomainはUIを知らない
- `Equatable` を継承する
- `const` コンストラクタ使用
- IDは `String`（UUID文字列）
