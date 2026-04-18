# 要件書: F-8 PaymentDetail 売上項目追加・OverView 収支合計表示

- **要件ID**: REQ-payment_detail_sales
- **作成日**: 2026-04-18
- **担当**: product-manager
- **タスク**: T-504
- **ステータス**: 確定

---

## 1. 概要

PaymentDetail に「売上」項目を追加し、訪問作業（visitWork）のイベント概要（OverView）セクションに支払項目一覧と収支合計（売上 - 支払）を表示する。

個人事業主が訪問作業の売上と経費を一元管理し、1回の訪問での収支を把握できるようにする。

---

## 2. ユーザーストーリー

- 訪問作業者として、売上金額をイベントに記録したい。請求書と照合する根拠にしたい。
- 訪問作業者として、1回の訪問作業での収支（売上 - 支出）を概要タブで一目で確認したい。
- 訪問作業者として、どの支払いが「売上（収入）」でどの支払いが「支出（経費）」かを区別したい。

---

## 3. 機能要件

### 3-1. PaymentDetail に売上/支出の区分を追加

PaymentDetail（PaymentDomain）に「支払種別」フィールドを追加する。

| フィールド | 型 | 説明 |
|---|---|---|
| `paymentType` | `PaymentType` enum | `expense`（支出・デフォルト）/ `revenue`（売上） |

- 既存の PaymentDetail はすべて `expense`（支出）として扱う（マイグレーション時のデフォルト値）
- PaymentDetail 登録フォームに「売上 / 支出」の切り替え UI を追加する
- 売上の場合は金額を正の値で入力し、内部的にも正の値で保存する（符号反転はしない）

### 3-2. OverView セクションに支払項目・収支合計を表示

visitWork トピックの概要（OverView）タブの集計セクション内に、以下を追加する。

#### 支払項目セクション

```
-- 支払い --

売上
  案件A作業代              +15,000
  追加作業代                +3,000
  ─────────────────
  売上合計                 +18,000

支出
  交通費（ガソリン）         -2,000
  材料費                    -1,500
  ─────────────────
  支出合計                  -3,500

━━━━━━━━━━━━━━━━━━━
収支合計                   +14,500
```

- 売上（`revenue`）と支出（`expense`）をグループ分けして表示する
- 各グループ内に PaymentDetail のメモ（品目名）と金額を一覧表示する
- メモが未入力の場合は「支払 #N」（N は通し番号）で代替表示する（既存 REQ-payment_info_redesign と同一ルール）
- グループごとの小計を表示する
- 最下部に収支合計（売上合計 - 支出合計）を表示する
- 金額表示: 売上は `+N` 形式・緑色、支出は `-N` 形式・赤色、収支合計は符号に応じて色分け

#### 配置位置

- visitWork の OverView セクション内で、既存の「売上サマリー」（売上合計・時給換算）を本セクションに置き換える
- 時給換算は本セクションの売上合計を使って引き続き表示する

### 3-3. EventDetail 支払タブのタブ名変更（visitWork のみ）

**要件ID**: REQ-PSales-01

visitWork トピックの `EventDetailPage` において、支払タブのラベルを「支払」から「**収支**」に変更する。

| 条件 | タブ名 |
|---|---|
| トピックが visitWork | 「収支」 |
| トピックが visitWork 以外（travelExpense / movingCost） | 「支払」（変更なし） |

- トピック種別に応じてタブラベルを動的に切り替える
- タブの機能・内容自体は変更しない（売上/支出の登録は 3-1 の PaymentType 区分で対応）
- タブ名の変更は表示ラベルのみ。ルーティングやキー名には影響しない

### 3-4. 既存の時給換算への影響

- 時給換算の計算元は「`revenue` 種別の PaymentDetail 合計」に変更する
- 現行の `AggregationResult.totalPayment` が全PaymentInfoの合計を返している場合、`revenue` のみの合計と `expense` のみの合計を分離する必要がある

---

## 4. 受け入れ条件

- [ ] PaymentDetail 登録時に「売上」または「支出」を選択できる
- [ ] 既存の PaymentDetail は「支出」として扱われる（後方互換性）
- [ ] visitWork の概要タブに売上・支出それぞれの項目一覧が表示される
- [ ] 収支合計（売上合計 - 支出合計）が正しく計算・表示される
- [ ] 時給換算は売上合計（revenue のみ）を使って計算される
- [ ] PaymentDetail が0件の場合、支払いセクションは非表示または「---」表示
- [ ] visitWork トピックの EventDetailPage で支払タブのラベルが「収支」と表示される（REQ-PSales-01）
- [ ] visitWork 以外のトピックでは支払タブのラベルが「支払」のまま変更されない（REQ-PSales-01）

---

## 5. 決定事項

### 5-1. 対象トピックのスコープ

**visitWork 専用** に確定。visitWork トピックの OverView のみに表示する。他トピック（travelExpense / movingCost）には影響しない。他トピックへの展開は別要件書で対応する。

### 5-2. 売上の入力単位

**PaymentDetail 1件ごと** に確定。既存の PaymentDetail と同じ粒度で1件ずつ登録する。メモ欄で品目名を記載する。理由: 既存の PaymentInfo の仕組みをそのまま流用でき、複数の売上品目（作業代・追加料金など）を個別管理できるため。

### 5-3. EventDetail 支払タブのタブ名

visitWork トピックの場合のみタブ名を「支払」から「**収支**」に変更する。他トピックは「支払」のまま変更しない。（REQ-PSales-01）

---

## 6. 前提・制約

- 設計憲章に従い BLoC パターンで実装する
- 計算ロジックは Adapter 層に配置し、View（Widget）に持たせない
- PaymentDomain のスキーマ変更を伴うため、drift マイグレーション（schemaVersion +1）が必要
- REQ-payment_from_mark_link（F-5: MarkDetail からの支払い登録）との整合性を保つこと。F-5 の markLinkID と本要件の paymentType は独立したフィールドとして共存する
- 既存の travelExpense / movingCost の OverView 表示には影響を与えない

---

## 7. 関連ドキュメント

| ドキュメント | 関連内容 |
|---|---|
| `docs/Requirements/REQ-visit_work_topic.md` | visitWork トピック全体要件。売上サマリー・時給換算の定義元 |
| `docs/Requirements/REQ-payment_info_redesign.md` | PaymentInfo UI 改善。PaymentListTile デザイン・精算セクション |
| `docs/Requirements/REQ-payment_from_mark_link.md` | F-5: MarkLink からの支払い登録。markLinkID フィールド追加 |
| `docs/Requirements/REQ-moving_cost_balance.md` | movingCost 収支バランス。収支表示の参考フォーマット |
| `docs/Spec/Features/FS-visit_work_topic.md` | visitWork Feature Spec。売上サマリー・VisitWorkAggregation の設計 |

---

## 8. 影響範囲（想定）

| レイヤー | 変更内容 |
|---|---|
| Domain | `PaymentDomain` に `paymentType: PaymentType` 追加 |
| Domain | `PaymentType` enum 新規追加（`expense` / `revenue`） |
| Repository | drift マイグレーション（PaymentTable に `paymentType` カラム追加） |
| Adapter | `VisitWorkAggregationAdapter` の売上計算を `revenue` 種別のみに変更 |
| Adapter | OverView 向けの売上・支出グルーピング Projection 算出ロジック追加 |
| Projection | 売上・支出別の項目リスト + 小計 + 収支合計の表示用データクラス追加 |
| View | PaymentDetail フォームに「売上/支出」切り替え UI 追加 |
| View | visitWork OverView の売上サマリーセクションを収支合計セクションに拡張 |
| View | EventDetailPage の支払タブラベルを visitWork 時のみ「収支」に動的切り替え（REQ-PSales-01） |
