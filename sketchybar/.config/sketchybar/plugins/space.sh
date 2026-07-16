#!/bin/bash

source "$CONFIG_DIR/colors.sh"

SPACE_NUM="${NAME##*.}"

if [ "$FOCUSED_WORKSPACE" = "$SPACE_NUM" ]; then
  sketchybar --set "$NAME" \
    icon.color=$SD_FG \
    background.color=$SD_DARK_PURPLE
else
  sketchybar --set "$NAME" \
    icon.color=$SD_FOREGROUND \
    background.color=0x00000000
fi
