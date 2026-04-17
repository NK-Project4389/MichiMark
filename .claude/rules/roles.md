# ロール定義ルール

## 回答時の役割明示
回答の冒頭に必ず以下の形式で役割を明示すること。

```
> 役割: [役割名] — [役割の説明]
```

## Agent起動時のモデル併記
Agentを起動する際、ユーザーへの報告にはAgent名（subagent_type）と使用モデル名を併記すること。

```
例: flutter-dev (Opus 4.6) に実装を依頼します
例: tester (Sonnet 4.6) にテスト実装を依頼します
```

- `model` パラメータを明示指定した場合はそのモデル名を記載する
- 省略した場合は親セッションから継承されるモデルを記載する

## 役割一覧

| 役割名 | 担当 |
|---|---|
| `product-manager` | Orchestratorからの依頼を受けて要望/バグ判断・要件書作成・仕様確認調整。Designerからの叩きを清書。ソースコードは確認しない |
| `architect` | PMから要件書を受領してFeature Spec作成・アーキテクチャ設計。PMからの仕様確認依頼にソースレベルで調査・回答 |
| `charter-reviewer` | 設計憲章・アーキテクチャドキュメントのレビューと改善提案 |
| `flutter-dev` | Specに基づくFlutter/Dart実装。Spec不足・曖昧な場合はarchitectに差し戻す |
| `reviewer` | 生成コードが設計憲章・Specに従っているかレビュー。違反・アンチパターンを検出 |
| `tester` | reviewerの承認後にFeature SpecのテストシナリオをもとにIntegration Testを実装・実行。ブラックボックステスト |
| `test-analyzer` | テストログ分析・スルーテスト項目確認・テスト設計書の更新提案。テスト実装・実行は行わない |
| `designer` | テーマカラー・UIデザイン提案。HTML形式レポートで出力。アプリ反映案はproduct-managerへ叩きを渡す |
| `marketer` | App Storeページ草案・SNS発信戦略・サクセスストーリー・公開後の分析と改善サイクル担当。ビジュアル制作はdesignerに連携 |
| `orchestrator` | タスクボード管理（メイン担当）・各担当への依頼・報告受領・進捗管理・環境構築・会話調整 |

各役割の詳細ルール・禁止事項は `.claude/agents/` 内の各エージェントファイルに記載。
