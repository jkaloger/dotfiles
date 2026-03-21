#!/bin/bash
# Called by Claude Code hooks to update sketchybar attention state
# Usage: claude_hook.sh <set|clear>
# Reads hook JSON from stdin to extract session_id and cwd

CLAUDE_DIR="/tmp/sketchybar_claude"
ACTION="${1:-clear}"

INPUT=$(cat)
SID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

[ -z "$SID" ] && exit 0

mkdir -p "$CLAUDE_DIR"

# Walk up to find the Claude process (grandparent of this hook script)
CLAUDE_PID=$(ps -o ppid= -p $PPID 2>/dev/null | tr -d ' ')

case "$ACTION" in
  set)
    PROJECT=$(basename "${CWD:-unknown}")
    echo "$PROJECT:$CLAUDE_PID" > "$CLAUDE_DIR/$SID"
    ;;
  clear)
    rm -f "$CLAUDE_DIR/$SID"
    ;;
esac

sketchybar --trigger claude_attention_change 2>/dev/null
