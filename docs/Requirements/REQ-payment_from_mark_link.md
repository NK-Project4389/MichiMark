# 要件書：MarkDetail / LinkDetail からの支払い登録（POST-1/F-5 統合）

## ID

REQ-payment_from_mark_link

## 概要

MarkDetail・LinkDetail 画面に支払セクションを追加し、その画面から直接 PaymentDetail を登録できるようにする。
登録した支払いは PaymentInfo タブにも反映される。
MarkDetail・LinkDetail が削除された場合、紐づく支払いもカスケード削除される。

---

## ユーザーストーリー

- ユーザーとして、MarkDetail 画面のまま支払いを追加したい。支払タブに移動する手間を省きたい。
- ユーザーとして、LinkDetail 画面のまま支払いを追加したい。
- ユーザーとして、どの地点・区間で発生した支払いかを一目で把握したい。
- ユーザーとして、PaymentInfo タブでもその支払いを編集・削除したい。
- ユーザーとして、地点・区間を削除したら紐づく支払いも一緒に消えてほしい。

---

## 機能要件

### 1. PaymentDomain に markLinkID フィールドを追加

| フィールド | 型 | 説明 |
|---|---|---|
| `markLinkID` | `MarkLinkID?` | 紐づく Mark / Link の ID。NULL = PaymentInfo タブから直接登録 |

### 2. MarkDetail / LinkDetail に支払セクション追加

- 画面下部に「支払い」セクションを設ける
- セクション内の UI は PaymentInfo タブと同様（支払いカードリスト＋合計金額）
- セクション右上に「＋」ボタンを配置
- 「＋」ボタン押下 → PaymentDetail 画面へ遷移（`markLinkID` を自動セット）
- セクション内のカードタップ → 該当 PaymentDetail を編集モードで開く
- 対象となる支払いカード = `markLinkID` がこの Mark / Link と一致するもの

### 3. PaymentDetail からの保存フロー

- PaymentDetail で保存を押した場合：
  1. PaymentDetail を保存（EventDetail 経由、既存フロー踏襲）
  2. 呼び出し元の MarkDetail / LinkDetail も保存する
  3. 元の MarkDetail / LinkDetail 画面に戻る

### 4. カスケード削除

- MarkDetail / LinkDetail が削除されたとき、`markLinkID` が一致する PaymentDetail をすべて削除する
- 削除は Repository 層で実施

### 5. PaymentInfo タブの表示リデザイン

#### グルーピング構造

```
日付セクション（MarkDetail/LinkDetail の ActionTimeLog の日付）
  └── 名称サブセクション（MarkDetail/LinkDetail の markLinkName）
        └── 支払いカード（markLinkID が一致する Payment）

※ markLinkID = NULL の直接登録支払いは「直接登録」セクションとして別枠表示
```

#### 日付の導出ルール

- MarkDetail / LinkDetail の `markLinkDate` フィールドの日付を使用

#### 直接登録支払い（markLinkID = NULL）

- 「直接登録」固定ラベルのセクションで表示
- 現在の PaymentInfo UI フローと同様

### 6. PaymentInfo タブからの編集・削除

- markLinkID の有無に関わらず、すべての PaymentDetail を編集・削除できる
- PaymentInfo から削除した場合、対応する MarkDetail / LinkDetail の支払セクションからも消える

### 7. MarkDetail / LinkDetail 支払セクションからの削除

- MarkDetail / LinkDetail の支払セクションでカードを削除した場合、PaymentInfo タブからも消える

---

## 非機能要件

- 既存 PaymentInfo タブからの直接登録フローは廃止しない
- PaymentDetail フォーム自体の変更は最小限にとどめる（markLinkID の内部セットのみ）

---

## スコープ外

- INV 系（招待機能）との連携
- MichiInfo タイムラインカードからの支払い登録（POST-1 当初案だが今回は対象外）
- 支払い一覧の並べ替え・フィルタ機能

---

## 影響範囲

| レイヤー | 変更内容 |
|---|---|
| Domain | `PaymentDomain` に `markLinkID: MarkLinkID?` 追加 |
| Repository | MarkLink削除時に `markLinkID` 一致する Payment をカスケード削除 |
| Bloc | `MarkDetailBloc` / `LinkDetailBloc` に支払セクション表示・＋ボタンイベント追加 |
| Bloc | `PaymentInfoBloc` の Projection をグルーピング対応に変更 |
| View | `MarkDetailPage` / `LinkDetailPage` に支払セクション追加 |
| View | `PaymentInfoPage` のグルーピング表示対応 |
| Adapter | `PaymentInfoProjectionAdapter` にグルーピングロジック追加 |
