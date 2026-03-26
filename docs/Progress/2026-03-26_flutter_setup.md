# 2026-03-26 Flutterプロジェクト初期セットアップ

## 完了した作業

- Flutterプロジェクト作成（`flutter/` サブディレクトリ、Flutter 3.41.5）
- pubspec.yaml整備（パッケージ追加・説明文更新）
  - flutter_bloc, equatable, go_router, drift, sqlite3_flutter_libs
  - path_provider, path, get_it, uuid, intl
  - drift_dev, build_runner（dev）
- フォルダ構造作成（設計憲章・アーキテクチャ図に準拠）
  - `lib/domain/transaction/`（event / mark_link / payment）
  - `lib/domain/master/`（member / trans / tag / action）
  - `lib/adapter/`, `lib/repository/`
  - `lib/features/` 以下 15 Feature（各 bloc/draft/projection/view）
- `lib/main.dart`, `lib/app/app.dart`, `lib/app/router.dart` 最小構成作成
- アーキテクチャ図にtransaction/master分類を反映

## 未完了の作業

- Domain層の実装（transaction: Event / MarkLink / Payment、master: Member / Trans / Tag / Action）
- Repository層のインターフェース定義
- Feature実装（event_list → event_detail → mark_detail/link_detail → payment_detail → selection → settings の順）

## 次回やること

- Domain層の実装から着手
  - `lib/domain/master/` 4エンティティ → `lib/domain/transaction/` 3エンティティの順
