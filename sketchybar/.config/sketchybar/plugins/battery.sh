#!/bin/bash

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ -z "$PERCENTAGE" ]; then
  exit 0
fi

sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%"
