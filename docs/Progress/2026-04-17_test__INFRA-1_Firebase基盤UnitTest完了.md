# INFRA-1: Firebase基盤 Unit Test 完了

## 完了した作業

### T-346b: テストコード実装
- `fake_cloud_firestore: ^4.1.0` / `firebase_auth_mocks: ^0.15.1` を dev_dependencies に追加
- `flutter/test/infra/firebase_infra_test.dart` を新規作成
- reviewer指摘2回を経てSpec整合性を確認・修正完了

### T-348: テスト実行
- ホストマシンで `flutter test test/infra/firebase_infra_test.dart` を実行
- **7PASS / 0FAIL / 1SKIP**

## テスト結果

| シナリオID | テスト名 | 結果 |
|---|---|---|
| TC-INFRA-001 | Anonymous AuthでUIDが発行される | PASS |
| TC-INFRA-002 | 既存UIDがある場合は再発行しない | PASS |
| TC-INFRA-003 | Apple Sign InでAnonymousアカウントにリンクできる | SKIP（ネイティブ呼び出しのためUnit Test不可） |
| TC-INFRA-004 | Firestoreにメンバーを保存・取得できる | PASS |
| TC-INFRA-005 | Firestoreにイベントを保存・取得できる | PASS |
| TC-INFRA-006 | driftからFirestoreへのデータ移行が完了する | PASS |
| TC-INFRA-007 | 移行完了後にschemaVersionが更新される | PASS |
| TC-INFRA-008 | 移行済み状態ではFirestoreから読み込む | PASS |

## 特記事項

- TC-INFRA-003（Apple Sign In linkWithApple）はネイティブUI呼び出し（SignInWithApple.getAppleIDCredential）を含むためUnit Test不可。明示的にSKIPとして記録。
- TC-INFRA-008の「DI切り替えロジック検証」はUnit Testの範囲を超えるため、TC-INFRA-010（Integration Test・Medium優先度）でのカバーとした。期待結果（Firestoreからデータが返る）は現テストで満たされている。
- TC-INFRA-009（Widget Test）・TC-INFRA-010（Integration Test）は今回のスコープ外。

## 次回セッションで最初にやること

TODOタスクを確認して次の実装タスクを選択する。
候補: UI-19アクションバッジ改善要件書（T-453）、UTIL-1 CSV出力（T-409）など。
