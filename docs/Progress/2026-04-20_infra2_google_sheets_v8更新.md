# 2026-04-20 INFRA-2 Google Sheets v8 更新完了

## 完了した作業

### T-407: Domain設計一覧 → Google Sheets 移行 + v8 更新

**更新内容（xlsx から欠落していたフィールド追加）**

| シート | 追加項目 | バージョン |
|---|---|---|
| MarkLink | `members`（参加メンバー）、`gasPayer`（ガソリン支払者） | v4 |
| Payment | `markLinkID`（MarkLink紐付けID）、`paymentType`（expense/revenue） | v5・v8 |
| Action | `toState`・`isToggle`・`togglePairId` | v2 |
| Action | `needsTransition` | v3 |
| Action | `endFlag` | v6 |
| **ActionTimeLogs** | **シート新規追加**（id, eventId, actionId, timestamp, adjustedAt, markLinkId, isDeleted, createdAt, updatedAt） | v2〜v7 |

**各シートの schemaVersion 備考を「現在値: v8」に更新**

**対象スプレッドシート（2件）**

| 名前 | URL |
|---|---|
| MichiMark Domain設計一覧 | https://docs.google.com/spreadsheets/d/1hwMQuhej1o-OHm4YhYX-2XiqyLAoN-3w65wlRVNjYCo/edit |
| Domain設計一覧 | https://docs.google.com/spreadsheets/d/13d2rywy_Kq7Nz1m0Ybzyvif_SVYZgFhKgmHmlG4W_sg/edit |

---

## 未完了

- T-408: 移行後の運用ルール整備（Google Sheets 参照・更新手順をドキュメント化）

---

## 次回セッションで最初にやること

1. **T-408: 移行後の運用ルール整備**（Google Sheets の URL・更新手順を docs/Domain/ か operations.md に記載）
2. **TEST-QUALITY-1 T-602**: Integration Test 固有データハードコード廃止（flutter-dev）
