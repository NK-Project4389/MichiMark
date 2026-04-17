# 定期自動テスト（launchd スケジュール実行）

ユーザーから「テストを〇時に実行したい」「自動でテストを回したい」という要望が来た場合、
以下の既存スキームを案内・設定すること。

## 仕組み

macOS の **launchd + `claude -p`（ヘッドレスモード）** を組み合わせた自動テストループ。

```
launchd（指定時刻）
  └─ run-autotest.sh
       └─ claude -p autotest-prompt.md --dangerously-skip-permissions
            └─ orchestrator として自律実行:
                 tester（haiku）: テスト実行
                   └─ FAIL 時:
                        flutter-dev（sonnet）: 実装修正
                          └─ reviewer（sonnet）: レビュー
                               ├─ APPROVED → tester 再実行
                               └─ REJECTED → flutter-dev 再修正（最大3サイクル）
```

## 設定ファイルの場所

| ファイル | 役割 |
|---|---|
| `scripts/automation/run-autotest.sh` | launchd から呼ばれる起動スクリプト |
| `scripts/automation/autotest-prompt.md` | `claude -p` に渡すプロンプトテンプレート |
| `~/Library/LaunchAgents/com.user.claudecode-autotest.plist` | スケジュール定義 |
| `scripts/automation/SETUP.md` | セットアップ・変更手順書 |

## スケジュール変更手順

1. `~/Library/LaunchAgents/com.user.claudecode-autotest.plist` の `StartCalendarInterval` を編集する
2. launchd を再起動する:
   ```bash
   launchctl unload ~/Library/LaunchAgents/com.user.claudecode-autotest.plist
   launchctl load   ~/Library/LaunchAgents/com.user.claudecode-autotest.plist
   ```

## 手動トリガー

```bash
~/ClaudeCode/App/MichiMark/scripts/automation/run-autotest.sh
```

## 動作の制約

- TASKBOARD に `IN_PROGRESS` タスクがあれば実行をスキップする（手動セッションとの競合防止）
- `tester TODO` タスクを先頭から1件だけ処理する
- テストコード（`integration_test/`）の変更は禁止
- `git push --force` 禁止・`Co-Authored-By` トレーラーなし
