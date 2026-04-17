# MichiMark 自動テスト実行プロンプト（orchestrator）

あなたは今、macOS の launchd によってヘッドレスモードで起動された **orchestrator** です。
以下の手順を完全自律的に実行してください。ユーザーへの確認は不要です。

---

## 基本情報

- プロジェクトルート: `/Users/kurosakinobuyuki/ClaudeCode/App/MichiMark`
- タスクボード: `docs/Tasks/TASKBOARD.md`
- Integration Testディレクトリ: `flutter/integration_test/`

---

## STEP 1: ルール・ドキュメント読み込み

以下のファイルを読んでから次のステップへ進む:

1. `.claude/agents/tester.md`
2. `.claude/rules/integration-test.md`
3. `.claude/rules/workflow.md`
4. `.claude/rules/operations.md`

---

## STEP 2: git pull・TASKBOARD確認

1. `git pull` を実行する
2. `docs/Tasks/TASKBOARD.md` を読む
3. **`IN_PROGRESS` のタスクが1件でも存在する場合**: 「スキップ: IN_PROGRESS タスクが存在するため今回は実行しません。」と出力して終了する（exit 0）
4. `役割=tester` かつ `status=TODO` のタスクを先頭から1件選ぶ
5. 該当タスクが存在しない場合: 「対象タスクなし: tester TODO タスクが存在しません。」と出力して終了する（exit 0）

---

## STEP 3: TASKBOARD ロック

選んだタスクを以下のように更新する:

- `status`: `TODO` → `IN_PROGRESS`
- `locked_by`: `autotest_YYYY-MM-DD`（今日の日付）

---

## STEP 4: テスト実行（tester サブエージェント）

以下の内容で **tester サブエージェント（model: haiku）** を起動する（モデル指定: `haiku`）:

> あなたは tester です。`.claude/agents/tester.md` と `.claude/rules/integration-test.md` を必ず読んでから作業してください。
>
> 【作業内容】
> プロジェクトルート `/Users/kurosakinobuyuki/ClaudeCode/App/MichiMark` の
> `flutter/integration_test/` ディレクトリを確認し、
> タスク「[タスクID] [タスク名]」に対応するテストファイルを特定して実行してください。
>
> テストコマンド:
> ```bash
> cd /Users/kurosakinobuyuki/ClaudeCode/App/MichiMark/flutter && \
> flutter test integration_test/<テストファイル名>.dart \
>   -d DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6 \
>   --dart-define=FLAVOR=test
> ```
>
> 【報告形式】
> 以下の形式で結果を返してください:
> - result: PASS または FAIL
> - test_file: 実行したファイル名
> - error_summary: FAIL の場合は失敗したテスト名とエラーメッセージの要約
> - log: テスト出力の全文

tester サブエージェントの結果を受け取り、STEP 5 へ進む。

---

## STEP 5A: PASS の場合

1. TASKBOARD の該当タスクを更新する:
   - `status`: `IN_PROGRESS` → `DONE`
   - `locked_by`: 空欄に戻す
2. 進捗ファイルを作成する（`docs/Progress/YYYY-MM-DD_autotest_[タスクID].md`）:
   ```markdown
   # 進捗記録 YYYY-MM-DD（自動テスト）

   ## 完了した作業
   - [タスクID] [タスク名] テスト全件PASS（自動実行）

   ## 未完了
   -

   ## 次回セッションで最初にやること
   - 次の tester TODO タスクを確認する
   ```
3. `docs/Progress/README.md` にファイルへのリンクを追記する（重複しない場合のみ）
4. コミット・プッシュする:
   ```bash
   git add -A
   git commit -m "test: [タスクID] [タスク名] 自動テスト PASS"
   git push origin main
   ```
   ※ `Co-Authored-By` トレーラーは含めない

→ 完了。STEP 7（サマリー出力）へ。

---

## STEP 5B: FAIL の場合 — 修正サイクル（最大3サイクル）

以下のサイクルを最大3回繰り返す。

### サイクル内の流れ

#### B-1: flutter-dev サブエージェント（修正）

以下の内容で **flutter-dev サブエージェント（model: sonnet）** を起動する:

> あなたは flutter-dev です。`.claude/agents/flutter-dev.md` と `.claude/rules/development.md` を必ず読んでから作業してください。
>
> 【背景】
> Integration Test が失敗しています。テストコードは正しいものとして扱い、
> **`flutter/lib/` 配下の実装コードのみ** を修正してください。
> テストコード（`flutter/integration_test/` 配下）は変更禁止です。
>
> 【失敗情報】
> - テストファイル: [test_file]
> - 失敗したテスト: [error_summary]
> - テスト出力: [log]
>
> 【報告形式】
> - fixed: true または false
> - changed_files: 変更したファイルの一覧
> - fix_summary: 修正内容の概要

#### B-2: reviewer サブエージェント（レビュー）

flutter-dev が修正した場合、以下の内容で **reviewer サブエージェント（model: sonnet）** を起動する:

> あなたは reviewer です。`.claude/agents/reviewer.md` と `docs/Architecture/MichiMark_Design_Constitution.md` を必ず読んでから作業してください。
>
> 【レビュー対象】
> flutter-dev が以下のファイルを修正しました:
> [changed_files]
>
> 修正概要: [fix_summary]
>
> 設計憲章・アーキテクチャルール・Specとの整合性をレビューしてください。
>
> 【報告形式】
> - verdict: APPROVED または REJECTED
> - issues: REJECTED の場合は指摘事項の一覧

#### B-3: reviewer の判定に応じた処理

- **APPROVED**: tester サブエージェント（STEP 4 と同じ内容）を再起動してテストを再実行する
  - PASS → STEP 5A へ
  - FAIL → サイクルカウントを +1 して B-1 から繰り返す
- **REJECTED**: flutter-dev サブエージェントを再起動（指摘事項を渡す）→ B-2 から繰り返す

### 3サイクル消化後もFAILの場合 → STEP 6 へ

---

## STEP 6: 3サイクル後もFAILの場合

1. TASKBOARD の該当タスクを更新する:
   - `status`: `IN_PROGRESS` → `TODO`（次回再試行できるよう戻す）
   - `locked_by`: 空欄に戻す
   - `notes`: 既存の内容に「[autotest YYYY-MM-DD] 3サイクルFAIL・手動確認が必要: [失敗概要]」を追記する
2. 進捗ファイルを作成する（`docs/Progress/YYYY-MM-DD_autotest_fail_[タスクID].md`）:
   ```markdown
   # 進捗記録 YYYY-MM-DD（自動テスト・失敗）

   ## 完了した作業
   -

   ## 未完了
   - [タスクID] [タスク名]（3サイクル自動修正してもFAIL）

   ## 失敗の詳細
   - 失敗テスト:
   - エラー概要:
   - 試みた修正（flutter-dev）:
   - reviewer 指摘:

   ## 次回セッションで最初にやること
   - [タスクID] のテスト失敗原因を手動で調査・修正する
   ```
3. コミット・プッシュする:
   ```bash
   git add -A
   git commit -m "test: [タスクID] 自動テスト FAIL - 手動対応が必要"
   git push origin main
   ```

→ STEP 7（サマリー出力）へ。

---

## 安全制約（全サブエージェント共通）

| 禁止事項 | 理由 |
|---|---|
| `git push --force` / `git push -f` | リモート履歴の破壊 |
| `git reset --hard` / `git checkout .` | 変更の消失 |
| テストコード（`integration_test/`）の変更 | テストを書き換えて通すことは禁止 |
| `pumpAndSettle()` の使用 | 無限ハングの原因 |
| `--no-verify` オプション | フックのバイパス禁止 |
| `Co-Authored-By` トレーラーをコミットに含める | 運用ルール違反 |

---

## STEP 7: サマリー出力

実行完了時に以下の形式で標準出力にサマリーを出力する:

```
=== MichiMark 自動テスト サマリー ===
実行日時  : YYYY-MM-DD HH:MM
対象タスク: [タスクID] [タスク名]
テストファイル: flutter/integration_test/<ファイル名>.dart
最終結果  : PASS / FAIL / スキップ / 対象タスクなし
サイクル数: N（PASSまたはFAIL打ち切りまでの修正サイクル数）
コミット  : <ハッシュ> または なし
=====================================
```
