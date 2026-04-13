# impl-schedule

MichiMarkの実装自動実行スケジュールを現在時刻から5時間30分後に登録するスキル。

## あなたがやること

以下の手順を**順番に**実行せよ。

---

### ステップ1: 現在UTC時刻を取得

```bash
date -u +"%M %H %d %m %Y"
```

を実行して `分 時 日 月 年` を取得する。

---

### ステップ2: 5時間30分後のcron式を計算

取得した `分・時・日・月` に5時間30分を加算する。

- 分が60以上 → 時に繰り上げ、分は `分 - 60`
- 時が24以上 → 日に繰り上げ、時は `時 - 24`
- 日の最大値は月ごとに異なる（4月=30日、1/3/5/7/8/10/12月=31日、2月=28日）

結果を `MM HH DD Mon *` 形式のcron式にする。

---

### ステップ3: ToolSearch で RemoteTrigger を取得

```
ToolSearch: select:RemoteTrigger
```

---

### ステップ4: トリガーを作成

以下の設定でRemoteTriggerを呼び出す。

- **action**: `"create"`
- **name**: `"MichiMark-impl-[YYYYMMDD-HHMM]"`（現在時刻JST換算でよい）
- **cron_expression**: ステップ2で計算した式
- **environment_id**: `env_01PWUv5BxqirBHQxM1viEL98`
- **model**: `claude-sonnet-4-6`
- **allowed_tools**: `["Bash", "Read", "Write", "Edit", "Glob", "Grep", "ToolSearch", "RemoteTrigger"]`
- **sources**: `[{"git_repository": {"url": "https://github.com/NK-Project4389/MichiMark"}}]`
- **prompt**: 下記の「実装エージェント指示」をそのまま使う

---

### 実装エージェント指示（promptに設定する文字列）

```
あなたはMichiMark実装エージェントです。以下の手順を順番に実行してください。

## STEP 0: 自己再スケジュール（最初に必ず実行）

`date -u +"%M %H %d %m %Y"` を実行して現在のUTC時刻を取得し、
5時間30分後のcron式（MM HH DD Mon *）を計算する。

ToolSearchで RemoteTrigger を取得し、以下の設定で新しいトリガーを作成する。
- name: "MichiMark-impl-[現在時刻]"
- cron_expression: 計算したcron式
- environment_id: env_01PWUv5BxqirBHQxM1viEL98
- model: claude-sonnet-4-6
- allowed_tools: ["Bash", "Read", "Write", "Edit", "Glob", "Grep", "ToolSearch", "RemoteTrigger"]
- sources: [{"git_repository": {"url": "https://github.com/NK-Project4389/MichiMark"}}]
- prompt: このプロンプト全文をそのままコピーして設定する

## STEP 1: タスクボード確認

`docs/Tasks/TASKBOARD.md` を読む。
statusが `TODO` のセクションがなければ作業完了。終了する。
TODOのセクションがある場合は STEP 2 へ進む。

## STEP 2: 実装サイクル（TODOセクションを上から1つずつ処理）

TODOセクションごとに以下のサイクルを実行する。

### 2-1. 事前確認
- 対象セクションの notes に記載の Spec（docs/Spec/Features/）を読む
- docs/Architecture/MichiMark_Design_Constitution.md を読む
- .claude/rules/development.md を読む

### 2-2. 実装（flutter-dev役）
- Specに基づいてFlutter/Dartコードを実装する
- 作業ディレクトリは `/flutter`（コマンドは `cd flutter && ...`）
- BLocパターン・設計憲章の依存方向を守る
- `cd flutter && dart analyze` でエラーがないことを確認する

### 2-3. テストコード実装（tester役）
- 対象FeatureのSpecに記載のテストシナリオをもとに integration test を実装する
- 格納先: `flutter/integration_test/`
- リファレンス: `flutter/integration_test/basic_info_tap_to_edit_test.dart`
- 各テストで `GetIt.I.reset()` → `router.go('/')` → `app.main()` の順で起動する
- `setUpAll` での `app.main()` 呼び出しは禁止

### 2-4. レビュー（reviewer役）
- 実装コードとテストコードが設計憲章・Specと整合しているか確認する
- 違反があればフィードバックをまとめて 2-2 / 2-3 に戻る
- 合格なら 2-5 へ進む

### 2-5. テスト実行（tester役）
シミュレーター UDID: DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6 を使う。

```
cd flutter && flutter test integration_test/<feature>_test.dart -d DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6
```

#### テスト結果の処理
- **全件PASS** → STEP 2-6 へ進む
- **FAILあり** → 原因を調査し、コード起因なら 2-2 へ、テストコード起因なら 2-3 へ戻る。修正後は 2-4 から再実行する

### 2-6. 完了処理
- `docs/Tasks/TASKBOARD.md` の該当セクションのstatusを `DONE`、`locked_by` を空欄に更新する
- `docs/Progress/` に進捗ファイルを作成・更新する（ファイル名: `YYYY-MM-DD_[作業内容].md`）
- `docs/Progress/README.md` のファイル一覧を更新する
- git add / git commit / git push する
  - コミットメッセージに `Co-Authored-By` トレーラーは含めない

次のTODOセクションがあれば STEP 2 を繰り返す。全セクション完了したら終了。
```

---

### ステップ5: 完了報告

トリガー作成後、以下の情報をユーザーに報告する。

- 実行予定時刻（JST換算）
- トリガーID
- 管理URL: `https://claude.ai/code/scheduled`
