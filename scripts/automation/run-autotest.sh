#!/bin/bash
# =============================================================================
# run-autotest.sh — MichiMark 自動テスト・修正ループ 起動スクリプト
# launchd から呼ばれる、または手動実行可能
# =============================================================================

set -euo pipefail

# =============================================================================
# 設定
# =============================================================================
PROJECT_DIR="/Users/kurosakinobuyuki/ClaudeCode/App/MichiMark"
SCRIPT_DIR="$PROJECT_DIR/scripts/automation"
PROMPT_FILE="$SCRIPT_DIR/autotest-prompt.md"
LOG_DIR="$PROJECT_DIR/logs/autotest"
LOCK_FILE="/tmp/claudecode-autotest-michimark.lock"

# launchd は minimal PATH のため明示的に設定
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export HOME="/Users/kurosakinobuyuki"
export LANG="ja_JP.UTF-8"

# =============================================================================
# ログ設定
# =============================================================================
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/autotest_${TIMESTAMP}.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# =============================================================================
# クリーンアップ（終了時に必ず実行）
# =============================================================================
cleanup() {
    local exit_code=$?
    rm -f "$LOCK_FILE"
    log "--- 終了: exit_code=$exit_code ---"
    exit $exit_code
}
trap cleanup EXIT INT TERM

# =============================================================================
# 二重起動防止
# =============================================================================
if [ -f "$LOCK_FILE" ]; then
    LOCK_PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "0")
    if [ "$LOCK_PID" != "0" ] && kill -0 "$LOCK_PID" 2>/dev/null; then
        log "エラー: すでに実行中です (PID: $LOCK_PID). 終了します。"
        exit 1
    else
        log "警告: 古いロックファイルを検出 (PID: $LOCK_PID). クリアして続行します。"
        rm -f "$LOCK_FILE"
    fi
fi
echo $$ > "$LOCK_FILE"

# =============================================================================
# 前提チェック
# =============================================================================
log "=== MichiMark 自動テスト起動 ==="
log "PID: $$"

if ! command -v claude &>/dev/null; then
    log "エラー: claude CLI が見つかりません。"
    log "  確認: which claude"
    log "  PATHを確認するか、スクリプト内の PATH 設定を修正してください。"
    exit 2
fi
log "claude: $(which claude) / $(claude --version 2>/dev/null || echo '不明')"

if ! command -v flutter &>/dev/null; then
    log "警告: flutter コマンドが見つかりません。"
    log "  claude が内部でフルパス指定するため実行継続します。"
fi

if [ ! -f "$PROMPT_FILE" ]; then
    log "エラー: プロンプトファイルが見つかりません: $PROMPT_FILE"
    exit 3
fi

if [ ! -d "$PROJECT_DIR" ]; then
    log "エラー: プロジェクトディレクトリが見つかりません: $PROJECT_DIR"
    exit 4
fi

# =============================================================================
# プロジェクトへ移動・状態確認
# =============================================================================
cd "$PROJECT_DIR"
log "作業ディレクトリ: $(pwd)"
log "現在のブランチ: $(git branch --show-current 2>/dev/null || echo '不明')"
log "最新コミット: $(git log -1 --oneline 2>/dev/null || echo '不明')"

# =============================================================================
# claude -p を実行
# =============================================================================
PROMPT=$(cat "$PROMPT_FILE")

log "--- claude -p 開始 ---"

# --dangerously-skip-permissions: 自動承認（launchd 無人実行に必須）
# --model sonnet: プロジェクト設定のモデル（変更する場合はここを修正）
claude -p "$PROMPT" \
    --dangerously-skip-permissions \
    --model sonnet \
    2>&1 | tee -a "$LOG_FILE"

CLAUDE_EXIT=${PIPESTATUS[0]}

log "--- claude -p 終了: exit_code=$CLAUDE_EXIT ---"

if [ "$CLAUDE_EXIT" -eq 0 ]; then
    log "正常完了"
else
    log "異常終了: claude がエラーを返しました (exit=$CLAUDE_EXIT)"
fi

exit "$CLAUDE_EXIT"
