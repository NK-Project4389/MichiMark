# 2026-04-07 tester エージェント追加・Integration Test基盤整備

## 完了した作業

### tester エージェント追加
- `.claude/agents/tester.md` を新規作成
  - ブラックボックステスト担当エージェントの定義
  - 参照可能ファイル・禁止ファイルの明記
  - テスト実装ルール・実行コマンド・出力形式の定義
  - 失敗時の引き継ぎフロー定義

### CLAUDE.md 更新
- 役割一覧テーブルに `tester` を追加（reviewerの下に）
- 実装・レビューサイクルルールにtesterを組み込み
- Flutter移行タスクのフローにtesterを追加
- architectに「テストシナリオ込み」のSpec作成を明示

### Feature Spec テンプレート更新
- `docs/Templates/Feature_Spec_Template.md` に「16. Test Scenarios」セクションを追加
- 前提条件・テストシナリオ一覧・シナリオ詳細の記述フォーマットを定義
- TC-001〜TC-004のサンプルシナリオを記載

### Integration Test 基盤整備
- `flutter/pubspec.yaml` に `integration_test` パッケージを追加（dev_dependencies）
- `flutter/integration_test/` ディレクトリを作成
- `flutter/integration_test/README.md` を作成（実行方法・テスト作成ルール）

## 未完了

なし

## 次回セッションで最初にやること

- 次のFeature実装時に「16. Test Scenarios」セクションをSpecに含めてarchitectに依頼する
- testerエージェントを使ったIntegration Test実装・実行を試す
