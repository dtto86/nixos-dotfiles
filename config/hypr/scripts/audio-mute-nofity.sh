#!/run/current-system/sw/bin/bash

status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

if echo "$status" | grep -q MUTED; then
  notify-send -t 1000 -r 9995 "🔇 Audio Muted"
else
  notify-send -t 1000 -r 9995 "🔊 Audio Unmuted"
fi

