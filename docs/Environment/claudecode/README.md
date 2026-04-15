# Claude Code 設定バックアップ

`~/.claude/` 以下の設定ファイルのバックアップ。
環境移行時は各ファイルを `~/.claude/` の対応パスに配置する。

## ファイル構成

```
claudecode/
├── settings.json              → ~/.claude/settings.json
├── statusline-command.sh      → ~/.claude/statusline-command.sh
├── commands/
│   ├── context-check.md       → ~/.claude/commands/context-check.md
│   ├── sync-rules.md          → ~/.claude/commands/sync-rules.md
│   └── task.md                → ~/.claude/commands/task.md
└── skills/
    └── testflight/
        └── SKILL.md           → ~/.claude/skills/testflight/SKILL.md
```

## 復元手順

```bash
# settings.json（ローカルパスが含まれる場合は要修正）
cp settings.json ~/.claude/settings.json

# ステータスラインスクリプト
cp statusline-command.sh ~/.claude/statusline-command.sh

# カスタムコマンド
mkdir -p ~/.claude/commands
cp commands/* ~/.claude/commands/

# スキル
mkdir -p ~/.claude/skills/testflight
cp skills/testflight/SKILL.md ~/.claude/skills/testflight/SKILL.md
```

## 注意事項

- `settings.json` の `extraKnownMarketplaces` はローカル環境固有のパスのため除外済み
- `.claude/testflight.json`（APIキー等の認証情報）はセキュリティのためバックアップ対象外
