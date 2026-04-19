# 2026-04-20 F-8 PaymentDetail売上追加・OverView収支集計 完了

## 完了した作業

### F-8: PaymentDetail売上追加 + OverView収支集計（T-506a〜T-508）

**実装 (17ファイル・schemaVersion v7→v8)**

| 分類 | 内容 |
|---|---|
| 新規作成 | `payment_type.dart`・`payment_balance_section_adapter.dart`・`payment_balance_section_projection.dart` |
| DB変更 | `schemaVersion v7→v8`・`payments.payment_type TEXT NOT NULL DEFAULT 'expense'` |
| Domain | `PaymentDomain` に `paymentType: PaymentType` 追加 |
| Adapter | `VisitWorkAggregationAdapter` revenue種別のみの合計に変更 |
| View | PaymentDetailPage 売上/支出セグメントコントロール追加 |
| View | VisitWorkOverviewView 収支セクション表示追加 |
| View | EventDetailPage 支払タブラベル visitWork 時のみ「収支」に動的切り替え |

**テスト: 4PASS/6SKIP/0FAIL**

| TC | 結果 | 備考 |
|---|---|---|
| TC-PDS-001 | PASS | セグメント表示確認 |
| TC-PDS-002〜007 | SKIP | キーパッド入力フロー設計課題（TEST-QUALITY-1で対応） |
| TC-PDS-008 | PASS | 0件時セクション非表示 |
| TC-PDS-009 | PASS | visitWork 支払タブ「収支」表示 |
| TC-PDS-010 | PASS | 他Topic 「支払」維持 |

**レビューサイクル:** 実装1回・テスト3回差し戻し（schemaVersion記載・ループバグ・キー名・enterAmount方式）を経てAPPROVED

### INFRA-2: Google Workspace MCP 認証設定

- `GDRIVE_CREDS_DIR=/Users/kurosakinobuyuki/ClaudeCode/App/MichiMark/.claude/` に変更
- `gcp-oauth.keys.json` 配置
- OAuth認証フロー完了（別ターミナルで実行）
- T-407 着手可能状態に。別セッションで継続

### その他

- `.gitignore` に oauth 認証ファイルを追加（`gcp-oauth.keys.json`・`google-oauth-token.json`・`.gdrive-server-credentials.json`）
- `eventDetail_tab_paymentInfo` Key追加（タブ検索の安定化）

---

## 未完了

- F-8 TC-PDS-002〜007 SKIP（PaymentDetail登録→概要タブ確認フロー）
- INFRA-2 T-407: Google Sheets 移行（別セッションで継続）

---

## 次回セッションで最初にやること

1. **F-8 DONEセクションをTASKBOARD_ARCHIVEへ移動**
2. **TEST-QUALITY-1 着手**
   - T-602: Integration Test 固有データハードコード廃止（flutter-dev）
   - T-603: PaymentDomain・BasicInfoBloc Unit Test追加（tester）
3. **INFRA-2 T-407**: `/restart` 後に Google Drive MCP で xlsx → Google Sheets 移行
