# 要件書: F-10 EndFlag機能（訪問作業 出発=完了）

作成日: 2026-04-17
作成者: product-manager
バージョン: 1.0
参照デザイン叩き: `docs/Design/draft/end_flag_card_design.html`

---

## 概要

ActionDomainに `endFlag: bool` フィールドを追加し、EndFlag=trueのアクションが記録された（ActionTimeLogが存在する）MarkiLinkカードを、MichiInfo上で「完了」ビジュアルに変更する機能を追加する。

EndFlagはコード定義のみで、設定UIはこのフェーズでは提供しない。
訪問作業トピック（TopicType.visitWork）では「出発」アクションをEndFlag=trueとして内部定義する。

---

## ユーザーストーリー

- ユーザーとして、現場を出発した地点カードが「完了済み」として一目で分かるようにしたい
  → 「出発」アクションが記録されると、そのMarkカードがグレーアウト＋「✓ 完了」バッジ表示になる
- ユーザーとして、タイムライン上で完了した地点と未完了の地点を素早く区別したい
  → 完了カードは上辺ライン・ドット・テキストがグレー化し、視覚的に明確に区別できる

---

## 機能要件

### REQ-EF-01: ActionDomainへのendFlagフィールド追加

- `ActionDomain` に `endFlag: bool`（デフォルト: false）フィールドを追加する
- endFlagはコード定義のみ。ユーザーが操作するUIは本フェーズでは提供しない
- 既存Actionすべてのデフォルト値はfalse
- DBマイグレーションが必要かどうかはarchitectがSpec作成時に判断する

### REQ-EF-02: 訪問作業トピックのEndFlag定義

- `TopicType.visitWork` の「出発」アクションを `endFlag: true` として内部定義する
- 他のアクション（到着・作業開始・作業終了等）は `endFlag: false`
- EndFlagを複数のアクションに設定した場合の動作：「いずれかのEndFlagアクションが記録されたら完了」とする（architectがSpec作成時にルールを確定する）

### REQ-EF-03: MarkLinkItemProjectionへのisDoneフィールド追加

- `MarkLinkItemProjection` に `isDone: bool` フィールドを追加する
- 判定ロジック：対象MarkのIDに対して、`endFlag: true` のアクションを持つ `ActionTimeLog` が存在する場合に `isDone: true` とする
- 具体的な判定処理の実装方針はarchitectがSpec作成時に設計する

### REQ-EF-04: 完了ビジュアル（推奨案A: グレーアウト + チェック）

`isDone: true` のMarkカードに以下のビジュアルを適用する。

**カード本体:**
- カード背景色: `#F9FAFB`（Gray 50）← 通常: `#FFFFFF`
- カードボーダー色: `#D1D5DB` ← 通常: `#E9ECEF`
- 上辺カラーライン色: `#9CA3AF`（Gray 400）← 通常: `#2B7A9B`（Teal）

**タイムラインドット（道路帯）:**
- ドット色: `#9CA3AF` ← 通常: `#2B7A9B`
- ドット内にチェックマーク（白色 ✓）を表示

**接続線:**
- 接続線色: `#D1D5DB` ← 通常: `#2B7A9B`

**テキスト:**
- 地点名テキスト: color `#9CA3AF` + TextDecoration.lineThrough（打ち消し線）← 通常: `#1A1A2E` / 装飾なし
- 日時・その他テキスト: color `#ADB5BD` ← 通常: `#6C757D`

**完了バッジ（カード右上）:**
- テキスト: `✓ 完了`
- バッジ背景色: `#F3F4F6`（Gray 100）
- バッジボーダー色: `#D1D5DB`
- テキスト: fontSize 10 / fontWeight Bold (w700) / color `#6B7280`（Gray 500）

**注意:**
- 既存の道路帯Canvas（_MichiTimelinePainter）に対して `isDone` フラグを渡し、ドット色・接続線色等を分岐する
- 既存の `isFuel` フラグと同様の追加方法を想定する（architectがSpec作成時に確認する）

---

## 非機能要件

- EndFlag設定のUIは本フェーズでは提供しない（コード定義のみ）
- `dart analyze` エラー・警告 0 を維持する
- 既存の訪問作業・他トピックのアクション記録ロジックに影響を与えない
- 完了カードのタップ操作（地点詳細画面への遷移等）は引き続き動作する

---

## スコープ外

- EndFlag設定UI（アクション編集画面でのトグルスイッチ）は Phase 2 以降
- 完了状態の取り消し（undone）操作
- 訪問作業以外のトピックでのEndFlag定義
- ダークテーマ対応
- 完了アニメーション（カードがフェードアウトする等）

---

## 受け入れ条件

- [ ] `ActionDomain` に `endFlag: bool`（デフォルト: false）フィールドが追加されている
- [ ] `MarkLinkItemProjection` に `isDone: bool` フィールドが追加されている
- [ ] 訪問作業トピックの「出発」アクションが `endFlag: true` で定義されている
- [ ] 「出発」ActionTimeLogが記録されたMarkカードの `isDone` が `true` になる
- [ ] 完了カードの背景色が `#F9FAFB`（グレー）で表示される
- [ ] 完了カードの上辺ラインが `#9CA3AF`（グレー）で表示される
- [ ] 完了カードのタイムラインドットが `#9CA3AF`（グレー）＋ チェックマーク（白）で表示される
- [ ] 完了カードの地点名テキストに打ち消し線（`#9CA3AF` 色）が付いている
- [ ] 完了カードの右上に「✓ 完了」バッジが表示される（背景: `#F3F4F6` / テキスト: `#6B7280`）
- [ ] 未完了カードは従来通りTeal系カラーで表示される
- [ ] 完了カードのタップ操作が引き続き動作する
- [ ] `dart analyze` エラー・警告 0

---

## 備考

- 採用デザイン: 推奨案A「グレーアウト + チェックマーク」（EndFlagデザイン叩き `docs/Design/draft/end_flag_card_design.html` より）
- 案Bの完了グリーン（Emerald #10B981）は既存Linkカードカラーと混同リスクがあるため不採用
- DBマイグレーション要否・isDone判定ロジックの具体的な実装はarchitectがSpec作成時に設計する
- EndFlag=trueのアクションが複数存在する場合のルールはarchitectが確定する
