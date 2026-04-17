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
2. `.claude/agents/flutter-dev.md`
3. `.claude/agents/reviewer.md`
4. `.claude/rules/integration-test.md`
5. `.claude/rules/workflow.md`
6. `.claude/rules/operations.md`

---

## STEP 2: git pull・TASKBOARD確認・タスク種別判定

1. `git pull` を実行する
2. `docs/Tasks/TASKBOARD.md` を読む
3. **`IN_PROGRESS` のタスクが1件でも存在する場合**: 「スキップ: IN_PROGRESS タスクが存在するため今回は実行しません。」と出力して終了する（exit 0）

### タスク種別の判定（優先順位順）

**優先① 実装タスク**: `役割=flutter-dev` かつ `status=TODO` のタスクを先頭から1件選ぶ
→ 見つかった場合、そのタスクが属する **フィーチャーグループ** を特定する（TAKSBOARDのセクション見出し、例: `BUG-5`・`UI-23`・`F-10`）
→ **STEP 3A（実装サイクル）** へ進む

**優先② テスト実行タスク**: `役割=tester` かつ `status=TODO` かつタスク名が「テスト実行」のタスクを先頭から1件選ぶ
→ **STEP 3B（テスト実行サイクル）** へ進む

**どちらも存在しない場合**: 「対象タスクなし: 実行可能なタスクが存在しません。」と出力して終了する（exit 0）

---

---

# ═══════════════════════════════════════════════
# 実装サイクル（STEP 3A〜6A）
# flutter-dev TODO タスクから開始するフル実装フロー
# ═══════════════════════════════════════════════

## STEP 3A: Spec・関連タスク特定

選んだ `flutter-dev TODO` タスクのフィーチャーグループ（例: `UI-23`・`BUG-5`）を特定し、以下を読み取る:

1. **Spec ファイルのパス**: 関連する `architect` タスクの `notes` 列から取得（例: `docs/Spec/Features/FS-michi_info_date_separator.md`）
2. **フィーチャーグループ内の全タスク**:
   - `a タスク`: `役割=flutter-dev`（実装）← 今回の対象
   - `b タスク`: `役割=tester`（テストコード実装）
   - `レビュータスク`: `役割=reviewer`
   - `テスト実行タスク`: `役割=tester`（タスク名が「テスト実行」）

3. Spec ファイルを読んで、フィーチャーの内容・テストシナリオ・スコープを把握する

---

## STEP 4A: TAKSBOARDロック（a タスク）

`a タスク`（flutter-dev 実装タスク）を更新する:
- `status`: `TODO` → `IN_PROGRESS`
- `locked_by`: `autotest_YYYY-MM-DD`

---

## STEP 5A: flutter-dev サブエージェント（実装）

以下の内容で **flutter-dev サブエージェント（model: sonnet）** を起動する:

> あなたは flutter-dev です。以下のファイルを必ず読んでから作業してください:
> - `.claude/agents/flutter-dev.md`
> - `.claude/rules/development.md`
> - `docs/Architecture/MichiMark_Design_Constitution.md`
> - Spec ファイル: [Spec ファイルのパス]
>
> 【作業内容】
> フィーチャー「[フィーチャーグループ名] [フィーチャー説明]」の実装を行ってください。
>
> タスク詳細:
> - タスクID: [a タスクID]
> - タスク名: [a タスク名]
> - notes: [a タスクの notes 列の内容]
>
> 実装対象: `flutter/lib/` 配下のファイル
> 禁止: テストコード（`flutter/integration_test/`）の変更
>
> 実装完了後、`dart analyze` を実行してエラーが 0 件であることを確認する。
>
> 【報告形式】
> - fixed: true または false
> - changed_files: 変更・追加したファイルの一覧
> - impl_summary: 実装内容の概要（Spec のどの要件をどう実装したか）
> - analyze_result: dart analyze の結果（"0件" または エラー内容）

flutter-dev の結果を受け取り、`fixed=false` または `analyze_result` にエラーがある場合は STEP 9A（後述の失敗処理）へ進む。

---

## STEP 6A: TAKSBOARDロック（b タスク）

`b タスク`（tester テストコード実装タスク）を更新する:
- `status`: `TODO` → `IN_PROGRESS`
- `locked_by`: `autotest_YYYY-MM-DD`

---

## STEP 7A: tester サブエージェント（テストコード実装）

以下の内容で **tester サブエージェント（model: haiku）** を起動する:

> あなたは tester です。以下のファイルを必ず読んでから作業してください:
> - `.claude/agents/tester.md`
> - `.claude/rules/integration-test.md`
> - Spec ファイル: [Spec ファイルのパス]（テストシナリオを確認する）
>
> 【作業内容】
> フィーチャー「[フィーチャーグループ名] [フィーチャー説明]」のテストコードを実装してください。
>
> タスク詳細:
> - タスクID: [b タスクID]
> - タスク名: [b タスク名]
> - notes: [b タスクの notes 列の内容]
>
> ⚠️ 実装コード（`flutter/lib/`）は参照しない。Specのテストシナリオのみを参照してテストコードを書く。
> テストファイル格納先: `flutter/integration_test/`
> 命名規則: Spec または既存ファイルのパターンに準拠する
>
> 実装パターンは `.claude/rules/integration-test.md` に厳密に従う（特に pumpAndSettle 禁止・startApp ヘルパー使用）。
>
> 【報告形式】
> - fixed: true または false
> - test_file: 作成・更新したテストファイル名
> - scenarios: 実装したテストシナリオ一覧（TC-XXX-NNN 形式）
> - impl_summary: 実装内容の概要

tester の結果を受け取り、`fixed=false` の場合は STEP 9A へ進む。

---

## STEP 8A: reviewer サブエージェント（整合確認）

`レビュータスク` を IN_PROGRESS に更新してから、以下の内容で **reviewer サブエージェント（model: sonnet）** を起動する:

> あなたは reviewer です。以下のファイルを必ず読んでから作業してください:
> - `.claude/agents/reviewer.md`
> - `docs/Architecture/MichiMark_Design_Constitution.md`
> - Spec ファイル: [Spec ファイルのパス]
>
> 【レビュー対象】
> フィーチャー「[フィーチャーグループ名]」の実装とテストコード。
>
> ■ 実装（flutter-dev）:
> - 変更ファイル: [changed_files]
> - 実装概要: [impl_summary]
>
> ■ テストコード（tester）:
> - テストファイル: [test_file]
> - テストシナリオ: [scenarios]
>
> 以下を確認してください:
> 1. 実装が設計憲章・BLocパターン・Specに準拠しているか
> 2. テストコードが Spec のシナリオをカバーしているか
> 3. 実装とテストコードの整合性
>
> 【報告形式】
> - verdict: APPROVED または REJECTED
> - issues: REJECTED の場合は指摘事項の一覧（どのファイルの何が問題か）

### reviewer 判定に応じた処理

**APPROVED の場合**:
- `レビュータスク` を DONE に更新する
- STEP 10A（テスト実行）へ進む

**REJECTED の場合**:
- 指摘事項を flutter-dev・tester それぞれに渡して修正させる（最大2サイクル）
- 修正後、reviewer を再起動して再レビューする
- 2サイクル後も REJECTED なら STEP 9A へ進む

---

## STEP 9A: 実装フェーズ失敗時の処理

1. 各タスクのステータスを `IN_PROGRESS` → `TODO` に戻す（locked_by を空欄に）
2. `notes` に「[autotest YYYY-MM-DD] 自動実装失敗・手動確認が必要: [失敗概要]」を追記する
3. 進捗ファイルを作成する（`docs/Progress/YYYY-MM-DD_autotest_impl_fail_[フィーチャーID].md`）
4. コミット・プッシュする:
   ```bash
   git add -A
   git commit -m "chore: [フィーチャーID] 自動実装失敗 - 手動対応が必要"
   git push origin main
   ```
→ STEP 7（サマリー出力）へ

---

## STEP 10A: テスト実行タスクロック

`テスト実行タスク`（役割=tester、テスト実行）を更新する:
- `status`: `BLOCKED` → `IN_PROGRESS`
- `locked_by`: `autotest_YYYY-MM-DD`

→ **STEP 5（テスト実行）** へ進む

---

---

# ═══════════════════════════════════════════════
# テスト実行サイクル（STEP 3B）
# tester TODO（テスト実行）タスクから開始するフロー
# ═══════════════════════════════════════════════

## STEP 3B: TAKSBOARDロック（テスト実行タスク）

選んだテスト実行タスクを以下のように更新する:
- `status`: `TODO` → `IN_PROGRESS`
- `locked_by`: `autotest_YYYY-MM-DD`

→ **STEP 5（テスト実行）** へ進む

---

---

# ═══════════════════════════════════════════════
# 共通: テスト実行フロー（STEP 5〜）
# 実装サイクル・テスト実行サイクル 両方が合流するポイント
# ═══════════════════════════════════════════════

## STEP 5: tester サブエージェント（テスト実行）

以下の内容で **tester サブエージェント（model: haiku）** を起動する:

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
> - result: PASS または FAIL
> - test_file: 実行したファイル名
> - error_summary: FAIL の場合は失敗したテスト名とエラーメッセージの要約
> - log: テスト出力の全文

tester サブエージェントの結果を受け取り、STEP 6 へ進む。

---

## STEP 6A_pass: PASS の場合

1. TASKBOARD の該当タスク（テスト実行タスク・a タスク・b タスク）を更新する:
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
   - 次の自動実行対象タスクを確認する
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

## STEP 6B_fail: FAIL の場合 — 修正サイクル（最大3サイクル）

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

- **APPROVED**: tester サブエージェント（STEP 5 と同じ内容）を再起動してテストを再実行する
  - PASS → STEP 6A_pass へ
  - FAIL → サイクルカウントを +1 して B-1 から繰り返す
- **REJECTED**: flutter-dev サブエージェントを再起動（指摘事項を渡す）→ B-2 から繰り返す

### 3サイクル消化後もFAILの場合 → STEP 6C へ

---

## STEP 6C: 3サイクル後もFAILの場合

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
| テストコード（`integration_test/`）の変更（修正サイクル中） | テストを書き換えて通すことは禁止 |
| `pumpAndSettle()` の使用 | 無限ハングの原因 |
| `--no-verify` オプション | フックのバイパス禁止 |
| `Co-Authored-By` トレーラーをコミットに含める | 運用ルール違反 |

---

## STEP 7: サマリー出力

実行完了時に以下の形式で標準出力にサマリーを出力する:

```
=== MichiMark 自動テスト サマリー ===
実行日時  : YYYY-MM-DD HH:MM
サイクル種別: 実装サイクル / テスト実行サイクル
対象タスク: [タスクID] [タスク名]
テストファイル: flutter/integration_test/<ファイル名>.dart
最終結果  : PASS / FAIL / スキップ / 対象タスクなし
サイクル数: N（PASSまたはFAIL打ち切りまでの修正サイクル数）
コミット  : <ハッシュ> または なし
=====================================
```
