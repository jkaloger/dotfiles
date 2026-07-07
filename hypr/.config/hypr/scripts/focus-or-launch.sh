#!/bin/bash
# focus-or-launch.sh <class-regex> <command...>
# Focus first window whose class matches (case-insensitive), else launch.

class="$1"
shift

addr=$(hyprctl clients -j | jq -r --arg c "$class" \
  '[.[] | select(.class | test($c; "i"))][0].address // empty')

if [ -n "$addr" ]; then
  hyprctl dispatch focuswindow "address:$addr" >/dev/null
else
  exec "$@"
fi
