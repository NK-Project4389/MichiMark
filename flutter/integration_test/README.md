# Integration Tests

このディレクトリはブラックボックス統合テストを格納する。

## 実行方法

```bash
# iOSシミュレーターで実行
flutter test integration_test/[feature_name]_test.dart -d [device_id]

# 利用可能なデバイス一覧確認
flutter devices
```

## テスト作成ルール

- Feature Specの「テストシナリオ」セクションのみを参照する
- 実装ファイル（lib/）は参照しない（ブラックボックス）
- ファイル名: `[feature_name]_test.dart`
- テスト名にシナリオID（TC-001等）を含める
