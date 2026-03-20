#!/bin/bash

source "$CONFIG_DIR/plugins/stats_helpers.sh"

PAGES_ACTIVE=$(vm_stat | awk '/Pages active/{gsub(/\./,""); print $3}')
PAGES_WIRED=$(vm_stat | awk '/Pages wired/{gsub(/\./,""); print $4}')
PAGES_COMPRESSED=$(vm_stat | awk '/Pages occupied by compressor/{gsub(/\./,""); print $5}')
PAGE_SIZE=$(sysctl -n vm.pagesize)
TOTAL=$(sysctl -n hw.memsize)

if [ -z "$PAGES_ACTIVE" ] || [ -z "$PAGES_WIRED" ] || [ -z "$PAGES_COMPRESSED" ]; then
  exit 0
fi

USED=$(( (PAGES_ACTIVE + PAGES_WIRED + PAGES_COMPRESSED) * PAGE_SIZE ))
PCT=$(( USED * 100 / TOTAL ))

SPARK=$(sparkline /tmp/sketchybar_stats/mem_hist "$PCT")
USED_FMT=$(format_bytes "$USED")

sketchybar --set "$NAME" label="${SPARK} ${USED_FMT}"
