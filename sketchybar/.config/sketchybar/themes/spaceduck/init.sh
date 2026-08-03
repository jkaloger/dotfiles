#!/bin/bash

PLUGIN_DIR="$CONFIG_DIR/plugins"

source "$CONFIG_DIR/colors.sh"

sketchybar --bar \
  position=bottom \
  height=46 \
  color=$SD_BG \
  border_color=$SD_DARK_PURPLE \
  notch_width=0 \
  margin=0 \
  blur_radius=30 \
  y_offset=0 \
  padding_left=24 \
  padding_right=24

sketchybar --default \
  icon.font="JetBrainsMono Nerd Font Mono:Bold:14.0" \
  label.font="JetBrainsMono Nerd Font Mono:Medium:13.0" \
  icon.color=$SD_FG \
  label.color=$SD_FG \
  icon.shadow.drawing=on \
  icon.shadow.color=0x60000000 \
  icon.shadow.distance=1 \
  label.shadow.drawing=on \
  label.shadow.color=0x60000000 \
  label.shadow.distance=1 \
  background.drawing=off \
  padding_left=5 \
  padding_right=5 \
  label.padding_left=4 \
  label.padding_right=4 \
  icon.padding_left=8 \
  icon.padding_right=4

sketchybar --add event aerospace_workspace_change
sketchybar --add event claude_attention_change

for i in $(seq 1 3); do
  sketchybar --add item space."$i" left \
    --set space."$i" \
      icon="$i" \
      label.drawing=off \
      icon.padding_left=12 \
      icon.padding_right=12 \
      background.height=24 \
      background.corner_radius=6 \
      background.color=0x00000000 \
      background.drawing=on \
      script="$PLUGIN_DIR/space.sh" \
    --subscribe space."$i" aerospace_workspace_change
done

sketchybar --add bracket spaces space.1 space.2 space.3 \
  --set spaces \
    background.drawing=on \
    background.color=0x3030365f \
    background.corner_radius=9 \
    background.height=30 \
    background.border_width=0 \
    background.border_color=$SD_DARK_PURPLE

sketchybar --add item front_app center \
  --set front_app \
    icon.drawing=off \
    label.font="JetBrainsMono Nerd Font Mono:Bold:13.0" \
    script="$PLUGIN_DIR/front_app.sh" \
  --subscribe front_app front_app_switched

sketchybar --add item tmux_session left \
  --set tmux_session \
    icon="" \
    icon.font.size=24 \
    icon.color=$SD_PURPLE \
    label.color=$SD_FOREGROUND \
    update_freq=5 \
    script="$PLUGIN_DIR/tmux_session.sh" \
  --subscribe tmux_session front_app_switched

sketchybar --add item claude left \
  --set claude \
    icon="󰚩" \
    icon.font.size=24 \
    icon.color=$SD_CYAN \
    label.color=$SD_FOREGROUND \
    drawing=off \
    update_freq=10 \
    script="$PLUGIN_DIR/claude.sh" \
  --subscribe claude claude_attention_change

sketchybar --add item battery right \
  --set battery \
    update_freq=120 \
    script="$PLUGIN_DIR/battery.sh" \
  --subscribe battery system_woke power_source_change

sketchybar --add item clock right \
  --set clock \
    update_freq=30 \
    script="$PLUGIN_DIR/clock.sh"

sketchybar --add item claude_usage right \
  --set claude_usage \
    icon="󰚩" \
    icon.font.size=18 \
    icon.color=$SD_CYAN \
    update_freq=60 \
    script="$PLUGIN_DIR/claude_usage.sh" \
    click_script="$PLUGIN_DIR/claude_usage.sh"

sketchybar --update
