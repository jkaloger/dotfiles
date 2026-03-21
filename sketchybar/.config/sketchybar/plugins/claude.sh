#!/bin/bash

source "$CONFIG_DIR/colors.sh"

CLAUDE_DIR="/tmp/sketchybar_claude"

if [ ! -d "$CLAUDE_DIR" ] || [ -z "$(ls -A "$CLAUDE_DIR" 2>/dev/null)" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

LABELS=""
for f in "$CLAUDE_DIR"/*; do
  [ -f "$f" ] || continue
  CONTENT=$(cat "$f" 2>/dev/null)
  PROJECT="${CONTENT%%:*}"
  PID="${CONTENT##*:}"

  # Prune if the owning Claude process is dead
  if [ -n "$PID" ] && ! kill -0 "$PID" 2>/dev/null; then
    rm -f "$f"
    continue
  fi

  [ -z "$PROJECT" ] && continue
  if [ -n "$LABELS" ]; then
    LABELS="$LABELS, $PROJECT"
  else
    LABELS="$PROJECT"
  fi
done

if [ -z "$LABELS" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ ${#LABELS} -gt 30 ]; then
  LABELS="${LABELS:0:30}…"
fi

sketchybar --set "$NAME" drawing=on label="$LABELS"
