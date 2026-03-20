#!/bin/bash

source "$CONFIG_DIR/plugins/stats_helpers.sh"

PREV_FILE="$STATS_DIR/net_prev"

read IBYTES OBYTES <<< $(netstat -ib -I en0 | awk 'NR==2{print $7, $10}')

NOW=$(date +%s)

if [ ! -f "$PREV_FILE" ]; then
  echo "$IBYTES $OBYTES $NOW" > "$PREV_FILE"
  LABEL=$(printf "↑%5s ↓%5s" "0B" "0B")
  sketchybar --set "$NAME" label="$LABEL"
  exit 0
fi

read PREV_IBYTES PREV_OBYTES PREV_TIME < "$PREV_FILE"

INTERVAL=$(( NOW - PREV_TIME ))
[ "$INTERVAL" -le 0 ] && INTERVAL=3

DELTA_IN=$(( (IBYTES - PREV_IBYTES) / INTERVAL ))
DELTA_OUT=$(( (OBYTES - PREV_OBYTES) / INTERVAL ))

[ "$DELTA_IN" -lt 0 ] && DELTA_IN=0
[ "$DELTA_OUT" -lt 0 ] && DELTA_OUT=0

UP_FMT=$(format_bytes "$DELTA_OUT")
DOWN_FMT=$(format_bytes "$DELTA_IN")

LABEL=$(printf "↑%5s ↓%5s" "$UP_FMT" "$DOWN_FMT")
sketchybar --set "$NAME" label="$LABEL"

echo "$IBYTES $OBYTES $NOW" > "$PREV_FILE"
