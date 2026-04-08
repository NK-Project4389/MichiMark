# 運用ルール

## Git操作

- セッション開始時に自動でPullする
- 編集完了後に自動でPushする
- コンフリクト・エラーが発生した場合のみユーザーに確認する
- コミットメッセージに `Co-Authored-By` トレーラーを含めない

## 進捗記録

- セッション開始時に `docs/Progress/README.md` を確認し最新の進捗ファイルを読む
- 記録場所: `docs/Progress/YYYY-MM-DD_[作業内容].md`
- **git push を実行するタイミングで必ず進捗ファイルを作成・更新する**
- セッション終了時またはユーザーが求めた際も作成・更新する
- 記録内容：完了した作業・未完了・**次回セッションで最初にやること（具体的なタスク名）**
- 新規ファイル作成時は `docs/Progress/README.md` のファイル一覧も更新する

## タスクボード運用

複数セッションが並行して作業する際の競合を防ぐため、タスクボードで着手状況を共有する。

- **セッション開始時に `docs/Tasks/TASKBOARD.md` を必ず読む**
- `IN_PROGRESS` のタスクには別セッションは手を出さない
- タスクに着手するとき → `status` を `IN_PROGRESS`、`locked_by` に `YYYY-MM-DD_[作業内容]` を記入して保存
- タスク完了時 → `status` を `DONE`、`locked_by` を空欄に戻す
- **作業完了時にタスクボードの `DONE` 更新を忘れないこと**（コミットと同タイミングで更新する）
- 依存タスクが未完了の場合は `BLOCKED` のまま待つ
- タスクボードを更新した後は即座にコミット・プッシュして他セッションに共有する

## ドキュメント参照

| ドキュメント | 用途 |
|---|---|
| `docs/Architecture/MichiMark_Design_Constitution.md` | 設計憲章 |
| `docs/Architecture/MichiMark_Architecture_Diagram.md` | アーキテクチャ図 |
| `docs/Templates/Feature_Spec_Template.md` | Feature仕様テンプレート |
| `docs/Spec/Features/` | Feature Spec格納ディレクトリ |
| `docs/Requirements/` | 要件書格納ディレクトリ |
| `docs/Domain/` | Domain設計MDファイル格納ディレクトリ |
| `docs/Design/` | デザインレポート格納ディレクトリ |
| `docs/Design/draft/` | designer が作成する要件の叩き格納ディレクトリ |
| `docs/Progress/README.md` | 進捗記録一覧 |
| `docs/Tasks/TASKBOARD.md` | セッション間共有タスクボード |
