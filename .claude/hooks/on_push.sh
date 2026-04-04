#!/bin/bash
# git push後に自動で進捗ファイルを作成・更新するhook

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

# git push コマンドが含まれているか確認
if ! echo "$COMMAND" | grep -q "git push"; then
    exit 0
fi

DATE=$(date +%Y-%m-%d)
REPO="/Users/kurosakinobuyuki/ClaudeCode/App/MichiMark"
PROGRESS_DIR="$REPO/docs/Progress"

cd "$REPO" || exit 0

# 最新コミットメッセージを取得
LATEST_COMMIT=$(git log -1 --pretty=format:"%s" 2>/dev/null)
COMMIT_HASH=$(git log -1 --pretty=format:"%h" 2>/dev/null)

# 今日の日付のファイルを検索
EXISTING=$(find "$PROGRESS_DIR" -name "${DATE}_*.md" | head -1)

if [ -z "$EXISTING" ]; then
    # 新規作成（作業内容はコミットメッセージから生成）
    SAFE_MSG=$(echo "$LATEST_COMMIT" | sed 's/[^a-zA-Z0-9ぁ-んァ-ンー一-龯]/_/g' | cut -c1-30)
    PROGRESS_FILE="$PROGRESS_DIR/${DATE}_${SAFE_MSG}.md"

    cat > "$PROGRESS_FILE" << EOF
# 進捗記録 ${DATE}

## 完了した作業
- ${LATEST_COMMIT} (${COMMIT_HASH})

## 未完了
-

## 次回セッションで最初にやること
-
EOF

    # README.md に追記
    FILENAME=$(basename "$PROGRESS_FILE")
    if ! grep -q "$FILENAME" "$PROGRESS_DIR/README.md" 2>/dev/null; then
        echo "- [${DATE}](./${FILENAME})" >> "$PROGRESS_DIR/README.md"
    fi
else
    # 「## 完了した作業」セクションの直後に追記
    python3 - "$EXISTING" "$LATEST_COMMIT" "$COMMIT_HASH" << 'PYEOF'
import sys

filepath = sys.argv[1]
commit_msg = sys.argv[2]
commit_hash = sys.argv[3]

with open(filepath, 'r') as f:
    lines = f.readlines()

insert_idx = None
for i, line in enumerate(lines):
    if line.strip() == '## 完了した作業':
        insert_idx = i + 1
        break

if insert_idx is not None:
    new_line = f'- {commit_msg} ({commit_hash})\n'
    lines.insert(insert_idx, new_line)
    with open(filepath, 'w') as f:
        f.writelines(lines)
PYEOF
fi
