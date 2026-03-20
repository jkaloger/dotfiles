#!/bin/bash

PLAYING=""

SPOTIFY=$(osascript -e '
  tell application "System Events"
    if (name of processes) contains "Spotify" then
      tell application "Spotify"
        if player state is playing then
          return (name of current track) & " — " & (artist of current track)
        end if
      end tell
    end if
  end tell
' 2>/dev/null)

if [ -n "$SPOTIFY" ]; then
  PLAYING="$SPOTIFY"
fi

if [ -z "$PLAYING" ]; then
  MUSIC=$(osascript -e '
    tell application "System Events"
      if (name of processes) contains "Music" then
        tell application "Music"
          if player state is playing then
            return (name of current track) & " — " & (artist of current track)
          end if
        end tell
      end if
    end tell
  ' 2>/dev/null)

  if [ -n "$MUSIC" ]; then
    PLAYING="$MUSIC"
  fi
fi

if [ -z "$PLAYING" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ ${#PLAYING} -gt 40 ]; then
  PLAYING="${PLAYING:0:40}…"
fi

sketchybar --set "$NAME" drawing=on label="$PLAYING"
