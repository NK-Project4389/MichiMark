# MichiMark 自動テスト セットアップ手順

## ファイル構成

```
scripts/automation/
  run-autotest.sh       # 起動スクリプト（launchd から呼ばれる本体）
  autotest-prompt.md    # claude -p に渡すプロンプトテンプレート
  SETUP.md              # このファイル

~/Library/LaunchAgents/
  com.user.claudecode-autotest.plist  # launchd ジョブ定義

logs/autotest/          # 実行ログ出力先（自動作成）
  autotest_YYYYMMDD_HHMMSS.log  # 実行ごとのログ
  launchd_stdout.log    # launchd 経由起動時の stdout
  launchd_stderr.log    # launchd 経由起動時の stderr
```

---

## 前提条件

| 項目 | 確認方法 |
|---|---|
| Claude CLI | `which claude` → `/opt/homebrew/bin/claude` が表示されること |
| Flutter | `flutter --version` |
| Xcode コマンドラインツール | `xcode-select -p` |
| iOS シミュレーター | `xcrun simctl list devices` に `DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6` が存在すること |
| git 認証 | `cd ~/ClaudeCode/App/MichiMark && git pull` が通ること |
| Claude 認証 | `claude --version` が正常に返ること |

---

## セットアップ手順

### 1. スクリプトに実行権限を付与

```bash
chmod +x ~/ClaudeCode/App/MichiMark/scripts/automation/run-autotest.sh
```

### 2. ログディレクトリ作成（初回のみ）

```bash
mkdir -p ~/ClaudeCode/App/MichiMark/logs/autotest
```

### 3. plist の構文確認

```bash
plutil -lint ~/Library/LaunchAgents/com.user.claudecode-autotest.plist
```

### 4. launchd にロード

```bash
launchctl load ~/Library/LaunchAgents/com.user.claudecode-autotest.plist
```

### 5. ロード確認

```bash
launchctl list | grep claudecode-autotest
```

正常にロードされていれば `com.user.claudecode-autotest` が表示される。

---

## 手動トリガー（テスト・動作確認用）

```bash
# 方法 1: スクリプト直接実行（ログも確認できる）
~/ClaudeCode/App/MichiMark/scripts/automation/run-autotest.sh

# 方法 2: launchctl 経由（plist の設定と同じ条件で実行）
launchctl start com.user.claudecode-autotest
```

---

## スケジュール変更方法

1. plist を編集する:

```bash
open ~/Library/LaunchAgents/com.user.claudecode-autotest.plist
```

`StartCalendarInterval` の `Hour` / `Minute` を変更する。

```xml
<!-- 例: 毎日 8:00 に変更 -->
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key>
    <integer>8</integer>
    <key>Minute</key>
    <integer>0</integer>
</dict>
```

2. launchd を再起動:

```bash
launchctl unload ~/Library/LaunchAgents/com.user.claudecode-autotest.plist
launchctl load   ~/Library/LaunchAgents/com.user.claudecode-autotest.plist
```

---

## 停止・アンロード

```bash
# 実行中のジョブを停止
launchctl stop com.user.claudecode-autotest

# launchd からアンロード（次回ログイン後は起動しない）
launchctl unload ~/Library/LaunchAgents/com.user.claudecode-autotest.plist
```

---

## ログの確認方法

```bash
# 最新の実行ログ
ls -lt ~/ClaudeCode/App/MichiMark/logs/autotest/ | head -5

# 最新ログの末尾を表示
tail -100 ~/ClaudeCode/App/MichiMark/logs/autotest/$(ls -t ~/ClaudeCode/App/MichiMark/logs/autotest/*.log | head -1 | xargs basename)

# launchd stdout ログ
tail -f ~/ClaudeCode/App/MichiMark/logs/autotest/launchd_stdout.log

# 過去ログをまとめて確認
ls ~/ClaudeCode/App/MichiMark/logs/autotest/autotest_*.log
```

---

## トラブルシュート

### claude が見つからない

```
エラー: claude CLI が見つかりません
```

`run-autotest.sh` の `PATH` 設定を確認する。`which claude` の出力パスが含まれているか確認:

```bash
which claude
# 例: /opt/homebrew/bin/claude
```

`/opt/homebrew/bin` が含まれていない場合は `run-autotest.sh` の以下の行を修正する:
```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
```

同様に plist の `EnvironmentVariables` > `PATH` も修正すること。

### launchd がジョブを起動しない

```bash
# launchd ログを確認
log show --predicate 'subsystem == "com.apple.launchd"' --last 1h | grep claudecode

# ジョブの状態確認
launchctl print gui/$(id -u)/com.user.claudecode-autotest
```

### 二重起動でスキップされた

ロックファイルが残っている可能性がある:

```bash
ls -la /tmp/claudecode-autotest-michimark.lock
# 残っていれば手動削除
rm -f /tmp/claudecode-autotest-michimark.lock
```

### シミュレーターが起動しない

```bash
# シミュレーター一覧確認
xcrun simctl list devices | grep DD988F7B

# 起動
xcrun simctl boot DD988F7B-F6D3-47B3-8830-3B2BE0E09FD6
```

### claude の認証切れ

```bash
# 認証状態確認
claude auth status

# 再認証
claude auth login
```

---

## カスタマイズポイント

| 設定 | ファイル | 変更箇所 |
|---|---|---|
| 実行スケジュール | `com.user.claudecode-autotest.plist` | `StartCalendarInterval` |
| 使用モデル | `run-autotest.sh` | `--model sonnet` 部分 |
| テスト実行デバイス UDID | `autotest-prompt.md` | `テスト実行デバイス UDID` 行 |
| リトライ上限回数 | `autotest-prompt.md` | `最大リトライ3回` 部分 |
| ログ保存先 | `run-autotest.sh` | `LOG_DIR` 変数 |

---

## 注意事項

- **Mac がスリープ中は実行されない。** 指定時刻にスリープしている場合はスキップされる。`caffeinate` や「電源オプション」で対処可能。
- `--dangerously-skip-permissions` フラグを使用しているため、claude はすべての操作を自動承認する。プロンプトの安全制約セクションをよく確認すること。
- ブランチ運用を変更したい場合（例: `auto-fix/日付` ブランチを使う）は `autotest-prompt.md` の STEP 5 のコミット・プッシュ手順を修正する。
