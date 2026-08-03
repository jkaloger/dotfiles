#!/bin/bash
mkdir -p "$HOME/.local/state/sketchybar"
echo "${1:-spaceduck}" > "$HOME/.local/state/sketchybar/theme"
sketchybar --reload
