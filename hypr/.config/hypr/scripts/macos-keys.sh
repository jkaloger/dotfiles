#!/bin/bash
# Translate macOS-style SUPER shortcuts to what the focused app expects.
# Terminals use CTRL+SHIFT for clipboard; plain CTRL+C there would be SIGINT.

action="$1"
class=$(hyprctl activewindow -j | jq -r '.class')

case "$class" in
  com.mitchellh.ghostty|ghostty|*[Kk]itty*|*[Aa]lacritty*|*foot*)
    mod="CTRL SHIFT"
    ;;
  *)
    mod="CTRL"
    ;;
esac

case "$action" in
  copy)      key=C ;;
  paste)     key=V ;;
  cut)       key=X ;;
  selectall) key=A; mod="CTRL" ;;
  undo)      key=Z; mod="CTRL" ;;
  *) exit 1 ;;
esac

hyprctl dispatch sendshortcut "$mod, $key," >/dev/null
