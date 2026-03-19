#!/bin/bash

source "$CONFIG_DIR/colors.sh"

SPACE_NUM="${NAME##*.}"

if [ "$FOCUSED_WORKSPACE" = "$SPACE_NUM" ]; then
  sketchybar --set "$NAME" icon.color=$SD_FG
else
  sketchybar --set "$NAME" icon.color=$SD_FOREGROUND
fi
