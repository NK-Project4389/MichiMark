# 進捗: 2026-04-09 セッション（TestFlight アップロード）

**日付**: 2026-04-09

---

## 完了した作業

### 1. TestFlight アップロード（ビルド 1.0.0 (3)）

- `flutter build ios --release` → ビルド成功
- `flutter build ipa` 経由でアーカイブ作成
- **エラー 91169**: `objective_c.framework` の arm64 スライスが `IOSSIMULATOR` プラットフォームとしてマークされていた
  - `vtool -set-build-version ios 13.0 13.0 -replace` で修正 → `codesign` で再署名
- **エラー 90208**: minos を `14.0` で設定したためアプリの最小OS（13.0）と不一致
  - minos を `13.0` に修正して再アップロード → `Upload succeeded` 確認

### 2. Podfile にシミュレータースライス除去フックを追加 (871018e / 673643a)

- `EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64`（Release ビルドでシミュレーター arm64 を除外）
- ビルドフェーズスクリプト `[MichiMark] Strip Simulator Slices` 追加
  - 全フレームワークを走査し IOSSIMULATOR タグを検出したら `vtool` で iOS に書き換え → `codesign` で再署名
  - minos は `13.0`（アプリの最小 OS バージョンに合わせる）
- `pod install` 適用済み

---

## 未完了 / 要対応

### 既存テスト失敗（UI変更に伴うテスト更新が必要）

| テストファイル | テストID | 原因 |
|---|---|---|
| `mark_addition_defaults_test.dart` | TC-MAD-006 | `IconButton.at(1)` でメンバー追加ボタンを探しているが UI 変更で順番が変わった |
| `mark_addition_defaults_test.dart` | TC-MAD-007 | AppBar の `Icons.check` 保存ボタンを探しているが概要タブ再設計で FAB に変更済み |
| `michi_info_layout_test.dart` | TS-03, TS-04 | Mark/Link タップ後の遷移確認テキストが UI 変更で変わった可能性 |

### 「給油計算」バグ
ユーザーから「給油計算がおかしい」と報告あり。FuelDetail の具体的な問題内容は未確認。

---

## 次回セッションで最初にやること

1. `docs/Tasks/TASKBOARD.md` を確認してタスクを確認する
2. 既存テスト失敗を修正する（TC-MAD-006/007、TS-03/04）
3. 「給油計算」バグの詳細をユーザーに確認する
