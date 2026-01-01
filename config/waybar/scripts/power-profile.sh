#!/run/current-system/sw/bin/bash

LOCK="$HOME/.local/state/powerprofile.lock"
profile=$(powerprofilesctl get)

if [ -f "$LOCK" ]; then
  echo "{\"text\":\"󰓅\",\"class\":\"locked\",\"tooltip\":\"Locked: $(cat "$LOCK")\"}"
  exit
fi

case "$profile" in
  performance)
    echo '{"text":"󰓅","class":"performance","tooltip":"Performance"}'
    ;;
  balanced)
    echo '{"text":"󰾅","class":"balanced","tooltip":"Balanced"}'
    ;;
  power-saver)
    echo '{"text":"󰾆","class":"powersaver","tooltip":"Power Saver"}'
    ;;
esac

