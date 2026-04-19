# MichiMark CLAUDE.md

## プロジェクト概要

MichiMarkはドライブ記録・マーク・リンク管理アプリ（SwiftUIからFlutterへ移植）。

- プラットフォーム：iOS / Android
- フレームワーク：Flutter / Dart
- 状態管理：flutter_bloc（BLoC パターン）
- DB：drift（SQLite）
- DI：get_it
- ナビゲーション：go_router

---

## Git操作ルール

- コミットメッセージに `Co-Authored-By` トレーラーを含めない

---

## Integration Test ルール

実装パターン・落とし穴・シードデータレビューは `.claude/rules/integration-test.md` を参照すること。
