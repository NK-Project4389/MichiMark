# 2026-04-15 INV-1 招待機能バックエンド Unit Test 実装・43件PASS

## 完了したこと

- `michimark-web/__tests__/invitation-service.test.ts` を新規作成
- `michimark-web/jest.config.ts` を新規作成（ts-jest + uuid ESMスタブ対応）
- `michimark-web/__mocks__/uuid.js` を新規作成（uuid ESMパッケージのCJSスタブ）
- `michimark-web/package.json` に `"test": "jest"` スクリプトを追加
- Jest / ts-jest / @types/jest を devDependencies にインストール済み（flutter-devが追加済み）

## テスト結果

| テスト種別 | ファイル | 件数 | 結果 |
|---|---|---|---|
| Unit | `__tests__/invitation-service.test.ts` | 43 | 全件PASS |

ログ: `docs/TestLogs/2026-04-15_16-56_INV1-unit.log`

## カバーしたシナリオ（Spec TC-INV1-xxx Unit種別）

| シナリオID | 内容 | 結果 |
|---|---|---|
| TC-INV1-002 | createInvitation - 権限なし（ownerUid不一致） | PASS |
| TC-INV1-003 | createInvitation - 存在しないeventId | PASS |
| TC-INV1-005 | validateInvitation - 有効期限切れ | PASS |
| TC-INV1-006 | validateInvitation - 使用回数上限 | PASS |
| TC-INV1-007 | validateInvitation / getInvitationByToken - 存在しないトークン | PASS |
| TC-INV1-009 | useInvitation - 有効期限切れ・usedCount変化なし | PASS |
| TC-INV1-010 | useInvitation - 使用回数上限 | PASS |
| TC-INV1-011 | useInvitation - 重複参加・usedCount変化なし | PASS |
| TC-INV1-013 | useInvitationByCode - 不正フォーマット（複数パターン） | PASS |
| TC-INV1-014 | useInvitationByCode / getInvitationByCode - 存在しないコード | PASS |
| TC-INV1-015 | useInvitation - 有効系・updateが呼ばれることを確認 | PASS |
| TC-INV1-016 | generateToken / generateCode - フォーマット・ユニーク性・リトライ | PASS |

## 技術的注意点（後続セッション向け）

- `uuid` パッケージがESM-only配信のため `__mocks__/uuid.js` でCJSスタブに差し替え済み
- Firestoreの `organizations/{orgId}/events/{eventId}/participants/{memberId}` は4段ネスト。
  `d3Doc` → `d2Col` → `d2Doc` → `d1Col` → `d1Doc` → `leafCol` → `leafDoc` の階層モックで対応
- `ValidateInvitationResult` の成功型は `{ invitation: InvitationDocument }`（`valid` フィールドなし）
- `useInvitation(token: string, { uid })` / `useInvitationByCode({ code, uid })` がlib層のエントリポイント

## 未完了（T-326a完了待ち）

- T-326a（flutter-dev による実装）が `IN_PROGRESS` のため T-328（テスト実行）は BLOCKED のまま
- reviewerレビュー（T-327）完了後に T-328 テスト実行フェーズへ移行する

## 次回セッションで最初にやること

1. T-326a の完了を確認する
2. reviewer に T-326a/b の整合確認（T-327）を依頼する
3. reviewer 承認後、Integration Test（TC-INV1-001, 004, 008, 012）の実行計画を立てる
