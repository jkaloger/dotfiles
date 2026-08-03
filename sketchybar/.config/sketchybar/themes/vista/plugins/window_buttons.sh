#!/bin/bash

export PATH="/run/current-system/sw/bin:$HOME/.nix-profile/bin:/opt/homebrew/bin:$PATH"

source "$CONFIG_DIR/themes/vista/colors.sh"

# hover repaint only; full sync recolors on exit
case "$SENDER" in
  mouse.entered)
    sketchybar --set "$NAME" background.color=$V_BTN_HOVER
    exit 0
    ;;
esac

AERO="$(command -v aerospace)"
[ -z "$AERO" ] && exit 0

LOCK="${TMPDIR:-/tmp}/sketchybar_winbtn.lock"
mkdir "$LOCK" 2>/dev/null || exit 0
trap 'rmdir "$LOCK"' EXIT

FOCUSED=$("$AERO" list-windows --focused --format '%{window-id}' 2>/dev/null)

# --query output is unreliable here; track our items in a state file instead
# (init.sh removes it on reload since reload drops all items)
STATE=/tmp/sketchybar_vista_winbtns
EXISTING=$(cat "$STATE" 2>/dev/null)

args=()
present=""
prev="window_sync"

while IFS='|' read -r id app title; do
  [ -z "$id" ] && continue
  item="win.$id"
  present="$present $item"
  [ -z "$title" ] && title="$app"
  [ ${#title} -gt 28 ] && title="${title:0:27}…"

  if ! printf '%s\n' "$EXISTING" | grep -qx "$item"; then
    # add separately so a duplicate-item error can't poison the batched call
    sketchybar --add item "$item" left \
      --set "$item" \
        icon=" " \
        icon.width=6 \
        icon.background.image="app.$app" \
        icon.background.image.scale=0.8 \
        label.font="$V_FONT:Medium:11.5" \
        label.padding_right=10 \
        background.drawing=on \
        background.corner_radius=4 \
        background.height=34 \
        background.border_width=1 \
        padding_left=3 \
        padding_right=3 \
        click_script="$AERO focus --window-id $id" \
      --subscribe "$item" mouse.entered mouse.exited 2>/dev/null
  fi

  args+=(--move "$item" after "$prev")
  prev="$item"

  if [ "$id" = "$FOCUSED" ]; then
    bg=$V_BTN_ACTIVE bd=$V_BTN_ACTIVE_BORDER
  else
    bg=$V_BTN bd=$V_BTN_BORDER
  fi
  args+=(--set "$item" label="$title" background.color=$bg background.border_color=$bd)
done < <("$AERO" list-windows --workspace focused --format '%{window-id}|%{app-name}|%{window-title}' 2>/dev/null)

for item in $EXISTING; do
  case " $present " in
    *" $item "*) ;;
    *) args+=(--remove "$item") ;;
  esac
done

[ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}"

printf '%s\n' $present > "$STATE"
