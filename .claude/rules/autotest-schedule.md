# 定期自動テスト（launchd スケジュール実行）

ユーザーから「テストを〇時に実行したい」「自動でテストを回したい」という要望が来た場合、
以下の既存スキームを案内・設定すること。

## 仕組み

macOS の **launchd + `claude -p`（ヘッドレスモード）** を組み合わせた自動テストループ。

TAKSBOARDの内容に応じて **実装サイクル** と **テスト実行サイクル** の2種類のフローを自動判定して実行する。

```
launchd（指定時刻）
  └─ run-autotest.sh
       └─ claude -p autotest-prompt.md --dangerously-skip-permissions
            └─ orchestrator として自律実行:

                 ┌─ flutter-dev TODO タスクがある場合（実装サイクル）─────────────────┐
                 │  flutter-dev（sonnet）: 実装                                        │
                 │    └─ tester（haiku）: テストコード実装                             │
                 │         └─ reviewer（sonnet）: 実装+テストコード整合レビュー        │
                 │              ├─ APPROVED → テスト実行フローへ                       │
                 │              └─ REJECTED → flutter-dev/tester 修正（最大2サイクル） │
                 └──────────────────────────────────────────────────────────────────────┘

                 ┌─ tester TODO（テスト実行）タスクがある場合（テスト実行サイクル）──┐
                 │  tester（haiku）: テスト実行                                        │
                 └──────────────────────────────────────────────────────────────────────┘

                 ─── 共通: テスト実行後 ───────────────────────────────────────────────
                 PASS → TASKBOARD更新 → 進捗ファイル作成 → git push
                 FAIL → flutter-dev（sonnet）: 実装修正
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
- タスクの優先順位: `flutter-dev TODO`（実装サイクル）> `tester TODO（テスト実行）`
- 1回の実行で処理するのは先頭1タスク（1フィーチャーグループ）のみ
- テストコード（`integration_test/`）の変更は修正サイクル中は禁止（初期実装時のみ可）
- `git push --force` 禁止・`Co-Authored-By` トレーラーなし
