#!/bin/bash

# sketchybar spawns plugins with launchd's bare PATH; claude lives in ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

source "$CONFIG_DIR/colors.sh"

CACHE="/tmp/sketchybar_claude_usage"

OUT=$(claude -p "/usage" 2>/dev/null)
SESSION=$(printf '%s' "$OUT" | sed -n 's/^Current session: \([0-9]*\)% used.*/\1/p' | head -n1)
# team plans can print extra weekly lines (e.g. "Current week (Opus)") — take all-models only
WEEK=$(printf '%s' "$OUT" | sed -n 's/^Current week (all models): \([0-9]*\)% used.*/\1/p' | head -n1)
[ -z "$WEEK" ] && WEEK=$(printf '%s' "$OUT" | sed -n 's/^Current week[^:]*: \([0-9]*\)% used.*/\1/p' | head -n1)

if [ -n "$SESSION" ] && [ -n "$WEEK" ]; then
  printf '%s %s' "$SESSION" "$WEEK" >"$CACHE"
elif [ -f "$CACHE" ]; then
  read -r SESSION WEEK <"$CACHE"
else
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

MAX=$SESSION
[ "$WEEK" -gt "$MAX" ] && MAX=$WEEK

COLOR=$SD_FG
if [ "$MAX" -ge 90 ]; then
  COLOR=$SD_RED
elif [ "$MAX" -ge 70 ]; then
  COLOR=$SD_ORANGE
fi

sketchybar --set "$NAME" drawing=on \
  label="S ${SESSION}% · W ${WEEK}%" \
  label.color="$COLOR"
