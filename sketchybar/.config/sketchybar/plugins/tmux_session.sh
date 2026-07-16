#!/bin/bash

SESSION=$(tmux display-message -p '#S' 2>/dev/null)

if [ -z "$SESSION" ]; then
  sketchybar --set "$NAME" drawing=off
  return 0 2>/dev/null || exit 0
fi

WINDOW_COUNT=$(tmux list-windows -t "$SESSION" 2>/dev/null | wc -l | tr -d ' ')

sketchybar --set "$NAME" drawing=on label="$SESSION [$WINDOW_COUNT]"
