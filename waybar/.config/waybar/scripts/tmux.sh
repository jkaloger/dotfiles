#!/bin/bash
# waybar port of sketchybar/plugins/tmux_session.sh

SESSION=$(tmux display-message -p '#S' 2>/dev/null)
WINDOW_COUNT=$(tmux list-windows 2>/dev/null | wc -l | tr -d ' ')

if [ -z "$SESSION" ]; then
  echo '{"text": ""}'
  exit 0
fi

echo "{\"text\": \"$SESSION [$WINDOW_COUNT]\"}"
