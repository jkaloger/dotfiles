#!/bin/bash

# fires for both the bar host item (start_orb) and the popup orb item (orb);
# the image always lives on the popup item
ASSETS="$CONFIG_DIR/themes/vista/assets"

case "$SENDER" in
  mouse.entered)
    sketchybar --set orb background.image="$ASSETS/orb_hover.png"
    ;;
  mouse.exited)
    sketchybar --set orb background.image="$ASSETS/orb_normal.png"
    ;;
  mouse.clicked)
    sketchybar --set orb background.image="$ASSETS/orb_pressed.png"
    open -a Raycast
    sleep 0.15
    sketchybar --set orb background.image="$ASSETS/orb_hover.png"
    ;;
esac
