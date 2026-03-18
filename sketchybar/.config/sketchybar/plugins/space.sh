#!/bin/bash

SPACE_NUM="${NAME##*.}"

if [ "$FOCUSED_WORKSPACE" = "$SPACE_NUM" ]; then
  sketchybar --set "$NAME" icon.color=0xffffffff
else
  sketchybar --set "$NAME" icon.color=0x80ffffff
fi
