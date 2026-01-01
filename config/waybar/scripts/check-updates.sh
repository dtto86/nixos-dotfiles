#!/bin/bash

# Check for updates
repo=$(checkupdates 2>/dev/null | wc -l)
aur=$(paru -Qua 2>/dev/null | wc -l)
total=$((repo + aur))

# Output for Waybar
if (( total > 0 )); then
  echo "󰏗 $total"
else
  echo "󱧖 "
fi

