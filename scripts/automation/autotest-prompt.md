# MichiMark 自動テスト・修正ループ — 実行プロンプト

あなたは今、macOS の launchd によってヘッドレスモードで起動されています。
以下の手順を **完全自律的に** 実行してください。ユーザーへの確認は不要です。

---

## 基本情報

- プロジェクトルート: `/Users/kurosakinobuyuki/ClaudeCode/App/MichiMark`
- Flutterディレクトリ: `/Users/kurosakinobuyuki/ClaudeCode/App/MichiMark/flutter`
- タスクボード: `docs/Tasks/TASKBOARD.md`
- Integration Testディレクトリ: `flutter/integration_test/`
- テスト実行デバイス UDID: `DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6`（iPhone 16 シミュレーター）

---

## STEP 1: 事前確認

1. `git pull` を実行してリモートの最新状態を取得する
2. `docs/Tasks/TASKBOARD.md` を読む
3. 以下の条件に一致するタスクを **先頭から1件だけ** 選ぶ:
   - `役割` が `tester`
   - `status` が `TODO`
4. 該当タスクが存在しない場合:
   - 「対象タスクなし: tester TODO タスクが存在しません。」と出力して終了する（exit 0）
5. `IN_PROGRESS` のタスクが存在する場合:
   - 「スキップ: IN_PROGRESS のタスクが存在するため今回は実行しません。」と出力して終了する（exit 0）

---

## STEP 2: テスト対象ファイルの特定

1. 選んだタスクの内容（タスク名・notes）から対応する integration test ファイルを `flutter/integration_test/` の中から特定する
2. ファイルが見つからない場合: TASKBOARD の当該タスクの notes 欄に「対応テストファイル不明: 手動確認が必要」と追記して終了する

---

## STEP 3: TASKBOARD ロック

TASkBOARDの該当タスクを以下のように更新する（ファイルを直接編集）:
- `status`: `TODO` → `IN_PROGRESS`
- `locked_by`: `autotest_YYYY-MM-DD`（今日の日付）

---

## STEP 4: テスト実行ループ（最大リトライ3回）

以下のコマンドでテストを実行する:

```bash
cd /Users/kurosakinobuyuki/ClaudeCode/App/MichiMark/flutter && \
flutter test integration_test/<テストファイル名>.dart \
  -d DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6 \
  --dart-define=FLAVOR=test
```

### テスト結果ごとの対応

#### PASS の場合 → STEP 5へ進む

#### FAIL の場合:

**試行1〜3回目:**

1. テストログを詳細に解析して失敗原因を特定する
2. **実装コード（`flutter/lib/` 配下）** を修正する
   - テストコード（`flutter/integration_test/` 配下）は **絶対に変更しない**
   - テスト側を書き換えて通すことは禁止
3. 修正後、テストを再実行する

**3回試みてもFAILの場合:**

- テストは一旦スキップして STEP 6（失敗時処理）へ進む

---

## STEP 5: PASS 時の処理

1. TASkBOARDの当該タスクを更新する:
   - `status`: `IN_PROGRESS` → `DONE`
   - `locked_by`: 空欄（`| |`）に戻す
2. 進捗ファイルを作成または更新する（`docs/Progress/YYYY-MM-DD_autotest_*.md`）:
   ```markdown
   # 進捗記録 YYYY-MM-DD（自動テスト）

   ## 完了した作業
   - [タスクID] [タスク名] テスト全件PASS

   ## 未完了
   -

   ## 次回セッションで最初にやること
   - 次の tester TODO タスクを確認する
   ```
3. `docs/Progress/README.md` にファイルへのリンクを追記する（重複しない場合のみ）
4. 変更をステージングしてコミットする:
   ```bash
   git add -A
   git commit -m "test: [タスクID] [タスク名] 自動テスト PASS"
   ```
   - `Co-Authored-By` トレーラーは **含めない**
5. プッシュする:
   ```bash
   git push origin main
   ```

---

## STEP 6: 3回FAIL後の処理

1. TASkBOARDの当該タスクを更新する:
   - `status`: `IN_PROGRESS` → `TODO`（次回再試行できるよう戻す）
   - `locked_by`: 空欄に戻す
   - `notes`: 既存の内容に「[autotest YYYY-MM-DD] 3回FAILのため手動確認が必要: <失敗の概要>」を追記する
2. 進捗ファイルを作成または更新する（`docs/Progress/YYYY-MM-DD_autotest_fail_*.md`）:
   ```markdown
   # 進捗記録 YYYY-MM-DD（自動テスト・失敗）

   ## 完了した作業
   -

   ## 未完了
   - [タスクID] [タスク名] 3回リトライしてもFAIL

   ## 失敗の詳細
   - 失敗テスト:
   - エラーメッセージ概要:
   - 試行した修正:

   ## 次回セッションで最初にやること
   - [タスクID] のテスト失敗原因を手動で調査・修正する
   ```
3. 変更をコミット・プッシュする:
   ```bash
   git add -A
   git commit -m "test: [タスクID] 自動テスト FAIL - 手動対応が必要"
   git push origin main
   ```

---

## 安全制約（必ず守ること）

| 禁止事項 | 理由 |
|---|---|
| `git push --force` または `git push -f` | リモート履歴の破壊につながる |
| `git reset --hard` または `git checkout .` | 変更の消失につながる |
| `main` 以外のブランチへのコミット | ブランチ管理ルール違反 |
| テストコード（`integration_test/`）の変更 | テストを書き換えて通すのは禁止 |
| `--no-verify` オプションの使用 | フックのバイパスは禁止 |
| `pumpAndSettle()` の使用 | 無限ハングの原因になる |
| 同じコマンドのリトライ（原因調査なしの再試行） | ルール違反 |

---

## 完了時の出力フォーマット

実行が完了したら、以下の形式で標準出力にサマリーを出力すること:

```
=== MichiMark 自動テスト サマリー ===
実行日時: YYYY-MM-DD HH:MM
対象タスク: [タスクID] [タスク名]
テストファイル: flutter/integration_test/<ファイル名>.dart
結果: PASS / FAIL（3回リトライ後）/ 対象タスクなし
試行回数: N回
適用した修正: （あれば概要）
コミット: <コミットハッシュ> または なし
=====================================
```
