#!/bin/bash

source "$CONFIG_DIR/plugins/stats_helpers.sh"

CPU_PCT=$(top -l 1 -n 0 2>/dev/null | awk '/CPU usage/{print int($3)}')

if [ -z "$CPU_PCT" ]; then
  exit 0
fi

SPARK=$(sparkline /tmp/sketchybar_stats/cpu_hist "$CPU_PCT")

LABEL=$(printf "%s %3d%%" "$SPARK" "$CPU_PCT")
sketchybar --set "$NAME" label="$LABEL"
