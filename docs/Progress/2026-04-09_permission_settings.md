# 2026-04-09 操作許可設定追加

## 完了した作業

- MichiMark・NomikaiShare 両プロジェクトの `.claude/settings.json` に操作許可を追加

### 追加した許可リスト（両プロジェクト共通）

| 許可ルール | 用途 |
|---|---|
| `Bash(flutter run*)` | アプリ実行 |
| `Bash(flutter pub*)` | パッケージ管理（pub get等） |
| `Bash(cd flutter && flutter *)` | cdつきflutterコマンド |
| `Bash(pod install*)` | iOS CocoaPods更新 |
| `Bash(xcodebuild *)` | Xcodeビルド（TestFlight等） |
| `Bash(open *)` | ファイル・アプリを開く |
| `Bash(ls*)` | ディレクトリ確認 |
| `Bash(mkdir*)` | ディレクトリ作成 |

## 未完了・次回やること

### 最優先（次回セッション開始時）
- **T-113: 走行コスト割り勘 実装**（flutter-dev）
  - Spec: `docs/Spec/Features/MovingCostFuelMode_Spec.md`
  - schemaVersion 3→4、全switch箇所に movingCostEstimated 追加
  - T-114（レビュー）→ T-115（テスト）と続く

### その後
- T-100〜103: カード挿入機能（Spec → 実装 → レビュー → テスト）
- T-120: 燃費更新機能 要件書作成
