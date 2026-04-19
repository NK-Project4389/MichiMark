# 2026-04-20 T-408: Google Sheets 運用ルール整備

## 完了した作業
- feat: T-603 Bloc/Domain Unit Test追加（第1弾） (86774b7)
- chore: T-408 Google Sheets 運用ルール整備（docs/Domain/README.md 作成・operations.md 更新） (b8735b0)

### T-408: INFRA-2 移行後の運用ルール整備

**作成・更新ファイル：**

| ファイル | 内容 |
|---|---|
| `docs/Domain/README.md`（新規作成） | Google Sheets URL・シート構成・更新手順・バージョン履歴を記載 |
| `.claude/rules/operations.md`（更新） | ドキュメント参照テーブルに Google Sheets リンクを追加 |

**記載内容：**
- Google Sheets（MichiMark Domain設計一覧）の URL
- シート構成と現在の schemaVersion（v8）
- スキーマ変更時の更新手順
- MCP ツール（gsheets_update_cell / gsheets_read）での更新方法
- `docs/Domain/*.md` と Google Sheets の関係（Sheets が正）
- バージョン履歴（v1〜v8）

---

## 未完了

- T-603: Bloc/Domain Unit Test 追加（PaymentDomain・BasicInfoBloc）- IN_PROGRESS
- T-604: Bloc/Domain Unit Test 追加（EventDetailBloc・OverviewBloc）- T-603完了後

---

## 次回セッションで最初にやること

1. **T-603: Unit Test 追加（PaymentDomain・BasicInfoBloc）** — tester (Haiku) で実装
