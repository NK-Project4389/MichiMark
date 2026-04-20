# 2026-04-20 T-408: Google Sheets 運用ルール整備

## 完了した作業
- fix+feat: Bug1/2修正・Feat1/2/3実装（visitWork支払・ActionTime休憩） (27f51d9)
- docs: UI-16 進捗ファイル更新（TF 1.1.0(13) アップロード完了） (f22e984)
- chore: UI-16 タスクボード完了更新・進捗ファイル追加 (faddf59)
- feat: T-421a UI-16 スプラッシュ画面実装 (05fef21)
- docs: TEST-QUALITY-1全タスク完了・Unit Test 47件追加セッション進捗登録 (399372c)
- test: T-604 Unit Test追加（VisitWorkAggregationAdapter・EventDetailBloc） (2699cc0)
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
