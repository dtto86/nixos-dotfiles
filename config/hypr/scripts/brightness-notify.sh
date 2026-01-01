#!/run/current-system/sw/bin/bash
level=$(brightnessctl get)
max=$(brightnessctl max)
percent=$((100 * level / max))
notify-send -t 1000 -r 9994 " Brightness" "$percent%"

