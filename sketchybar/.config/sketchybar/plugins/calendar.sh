#!/bin/bash

source "$CONFIG_DIR/colors.sh"

NEXT_EVENT=$(osascript -e '
  set now to current date
  set endOfDay to now + (24 * 60 * 60)
  tell application "Calendar"
    set allCals to calendars
    set nextEvent to missing value
    set nextDate to endOfDay
    repeat with cal in allCals
      set evts to (every event of cal whose start date >= now and start date < endOfDay)
      repeat with evt in evts
        if allday event of evt is false and start date of evt < nextDate then
          set nextDate to start date of evt
          set nextEvent to evt
        end if
      end repeat
    end repeat
    if nextEvent is not missing value then
      set mins to round ((nextDate - now) / 60)
      if mins < 60 then
        return (summary of nextEvent) & " in " & mins & "m"
      else
        set hrs to round (mins / 60)
        return (summary of nextEvent) & " in " & hrs & "h"
      end if
    end if
  end tell
' 2>/dev/null)

NOW_EVENT=$(osascript -e '
  set now to current date
  tell application "Calendar"
    set allCals to calendars
    repeat with cal in allCals
      set evts to (every event of cal whose start date <= now and end date > now)
      repeat with evt in evts
        if allday event of evt is false then return summary of evt
      end repeat
    end repeat
  end tell
' 2>/dev/null)

if [ -n "$NOW_EVENT" ]; then
  if [ ${#NOW_EVENT} -gt 25 ]; then
    NOW_EVENT="${NOW_EVENT:0:25}…"
  fi
  sketchybar --set "$NAME" drawing=on label="Now: $NOW_EVENT" label.color=$SD_ORANGE
  exit 0
fi

if [ -z "$NEXT_EVENT" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ ${#NEXT_EVENT} -gt 25 ]; then
  TITLE="${NEXT_EVENT%% in *}"
  SUFFIX="${NEXT_EVENT#* in }"
  if [ ${#TITLE} -gt 25 ]; then
    TITLE="${TITLE:0:25}…"
  fi
  NEXT_EVENT="$TITLE in $SUFFIX"
fi

sketchybar --set "$NAME" drawing=on label="$NEXT_EVENT" label.color=$SD_FG
