#!/bin/bash

STATS_DIR="/tmp/sketchybar_stats"
mkdir -p "$STATS_DIR"

sparkline() {
  local hist_file="$1"
  local value="$2"
  local blocks=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)

  touch "$hist_file"
  echo "$value" >> "$hist_file"
  tail -n 8 "$hist_file" > "${hist_file}.tmp"
  mv "${hist_file}.tmp" "$hist_file"

  local result=""
  while IFS= read -r v; do
    local idx=$(( v > 87 ? 7 : v > 75 ? 6 : v > 62 ? 5 : v > 50 ? 4 : v > 37 ? 3 : v > 25 ? 2 : v > 12 ? 1 : 0 ))
    result+="${blocks[$idx]}"
  done < "$hist_file"

  echo "$result"
}

format_bytes() {
  local bytes="$1"

  if [ "$bytes" -ge 1073741824 ] 2>/dev/null; then
    echo "$(echo "scale=1; $bytes / 1073741824" | bc)G"
    return
  fi

  if [ "$bytes" -ge 1048576 ] 2>/dev/null; then
    echo "$(echo "scale=1; $bytes / 1048576" | bc)M"
    return
  fi

  if [ "$bytes" -ge 1024 ] 2>/dev/null; then
    echo "$(echo "scale=1; $bytes / 1024" | bc)K"
    return
  fi

  echo "${bytes}B"
}
