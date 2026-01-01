#!/run/current-system/sw/bin/bash
volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
notify-send -t 1000 -r 9993 " Volume" "$volume%"

