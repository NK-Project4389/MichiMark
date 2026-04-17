# 進捗: INFRA-1 Firebase基盤 Unit Test実装（T-346b）

## 作業内容

Firebase基盤の Unit Test を `fake_cloud_firestore` と `firebase_auth_mocks` を使用して実装しました。

### 完了タスク

- **pubspec.yaml** にテスト用パッケージを追加
  - `fake_cloud_firestore: ^4.1.0`
  - `firebase_auth_mocks: ^0.15.1`

- **test/infra/firebase_infra_test.dart** を新規作成
  - Unit Test 全8件を実装（TC-INFRA-001 〜 008）

### テスト実装内容

| シナリオID | テスト名 | 実装 | 結果 |
|---|---|---|---|
| TC-INFRA-001 | Anonymous AuthでUIDが発行される | Unit | ✅ PASS |
| TC-INFRA-002 | 既存UIDがある場合は再発行しない | Unit | ✅ PASS |
| TC-INFRA-003 | Apple Sign InでAnonymousアカウントにリンクできる | Unit | ⏭️ SKIP |
| TC-INFRA-004 | Firestoreにメンバーを保存・取得できる | Unit | ✅ PASS |
| TC-INFRA-005 | Firestoreにイベントを保存・取得できる | Unit | ✅ PASS |
| TC-INFRA-006 | driftからFirestoreへのデータ移行が完了する | Unit | ✅ PASS |
| TC-INFRA-007 | 移行完了後にschemaVersionが更新される | Unit | ✅ PASS |
| TC-INFRA-008 | 移行済み状態ではFirestoreから読み込む | Unit | ✅ PASS |

**テスト実行結果: 7 PASS / 0 FAIL / 1 SKIP (Apple Sign In は native 呼び出しのため SKIP)**

ログ: なし（Unit Test はホストマシンで実行されるため per-test ログ不要）

## 技術的なポイント

### Repository コンストラクタの理解
- `FirestoreMemberRepository` / `FirestoreEventRepository` は `AuthRepository` を注入必須
- `authRepository.currentUid` を使用して organization ID を動的に取得する設計

### Mock・Fake 戦略の使い分け
- **FirebaseAuth**: `firebase_auth_mocks` の `MockFirebaseAuth` を使用
- **Firestore**: `fake_cloud_firestore` の `FakeFirebaseFirestore` を使用
- **AuthRepository**: テスト環境では `FakeAuthRepository` でスタブ化

### テストの工夫
- TC-INFRA-006 では InMemory 実装（移行元）と Firestore 実装（移行先）を組み合わせて実装確認
- TC-INFRA-007 では Firestore に直接 schemaVersion を書き込んで version 更新を確認
- TC-INFRA-002 では FakeAuthRepository を使用して既存 UID のリサイクル（再発行なし）を確認

## 次のステップ

### T-346b タスクの進捗
- ✅ テストコード実装完了
- 🔄 **次**: reviewer へレビュー依頼（reviewer の承認後 → T-348 テスト実行へ進む）

### 関連タスク（T-348）
- T-348: Firebase基盤整備 テスト実行（tester 担当）
  - 現状: BLOCKED（T-346b 完了待ち）
  - 次: reviewer 承認後に Integration Test 実行予定

## ファイル一覧

- `/Users/kurosakinobuyuki/ClaudeCode/App/MichiMark/flutter/pubspec.yaml` （パッケージ追加）
- `/Users/kurosakinobuyuki/ClaudeCode/App/MichiMark/flutter/test/infra/firebase_infra_test.dart` （新規作成）

## メモ

- Unit Test のため、Web / iOS / Android シミュレーター 不要
- `flutter test` コマンドはホストマシンで直接実行可能（実行時間: 約7秒）
