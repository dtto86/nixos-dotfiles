#!/run/current-system/sw/bin/bash

status=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)

if echo "$status" | grep -q MUTED; then
  notify-send -t 1000 -r 9996 "🎤 Mic Muted"
else
  notify-send -t 1000 -r 9996 "🎙️ Mic Unmuted"
fi

