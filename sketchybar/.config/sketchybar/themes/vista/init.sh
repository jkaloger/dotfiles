#!/bin/bash

source "$THEME_DIR/colors.sh"

VP="$THEME_DIR/plugins"
ASSETS="$THEME_DIR/assets"

rm -f /tmp/sketchybar_vista_winbtns

sketchybar --bar \
  position=bottom \
  height=32 \
  color=$V_BAR \
  blur_radius=28 \
  notch_width=0 \
  margin=0 \
  y_offset=0 \
  padding_left=0 \
  padding_right=0

sketchybar --default \
  icon.font="$V_FONT:Bold:13.0" \
  label.font="$V_FONT:Medium:12.0" \
  icon.color=$V_TEXT \
  label.color=$V_TEXT \
  label.shadow.drawing=on \
  label.shadow.color=0x80000000 \
  label.shadow.distance=1 \
  background.drawing=off \
  padding_left=4 \
  padding_right=4 \
  icon.padding_left=6 \
  icon.padding_right=2 \
  label.padding_left=4 \
  label.padding_right=6

sketchybar --add event aerospace_workspace_change
sketchybar --add event claude_attention_change

# the orb lives in a permanently-open popup: popups are separate windows that
# can render outside the bar, so pulling one down over the bar's top edge
# gives the Vista overflow without sinking the bar below the screen
sketchybar --add item start_orb left \
  --set start_orb \
    icon.drawing=off \
    label.drawing=off \
    width=72 \
    padding_left=2 \
    background.drawing=off \
    script="$VP/start_orb.sh" \
    popup.align=left \
    popup.y_offset=38 \
    popup.background.color=0x00000000 \
    popup.drawing=on \
  --subscribe start_orb mouse.entered mouse.exited mouse.clicked

sketchybar --add item orb popup.start_orb \
  --set orb \
    icon.drawing=off \
    label.drawing=off \
    width=60 \
    background.drawing=on \
    background.color=0x00000000 \
    background.image="$ASSETS/orb_normal.png" \
    background.image.scale=0.54 \
    script="$VP/start_orb.sh" \
  --subscribe orb mouse.entered mouse.exited mouse.clicked

sketchybar --add item window_sync left \
  --set window_sync \
    drawing=off \
    update_freq=3 \
    script="$VP/window_buttons.sh" \
  --subscribe window_sync aerospace_workspace_change front_app_switched

sketchybar --add item clock right \
  --set clock \
    icon.drawing=off \
    label.font="$V_FONT:Medium:12.0" \
    label.padding_left=8 \
    label.padding_right=12 \
    update_freq=30 \
    script="$VP/clock.sh"

sketchybar --add item battery right \
  --set battery \
    icon.font.size=13 \
    label.font.size=11 \
    update_freq=120 \
    script="$PLUGIN_DIR/battery.sh" \
  --subscribe battery system_woke power_source_change

sketchybar --add item claude_usage right \
  --set claude_usage \
    icon="󰚩" \
    icon.font.size=13 \
    label.font.size=11 \
    update_freq=60 \
    script="$PLUGIN_DIR/claude_usage.sh" \
    click_script="$PLUGIN_DIR/claude_usage.sh"

sketchybar --add item claude right \
  --set claude \
    icon="󰚩" \
    icon.font.size=13 \
    label.font.size=11 \
    drawing=off \
    update_freq=10 \
    script="$PLUGIN_DIR/claude.sh" \
  --subscribe claude claude_attention_change

sketchybar --add item tmux_session right \
  --set tmux_session \
    icon="" \
    icon.font.size=13 \
    label.font.size=11 \
    update_freq=5 \
    script="$PLUGIN_DIR/tmux_session.sh" \
  --subscribe tmux_session front_app_switched

sketchybar --add bracket tray battery claude_usage claude tmux_session \
  --set tray \
    background.drawing=on \
    background.color=$V_TRAY_BG \
    background.corner_radius=4 \
    background.height=32 \
    background.border_width=1 \
    background.border_color=$V_BTN_BORDER

sketchybar --update
