#!/bin/bash

if [ "$1" = "disconnect" ]; then
    chosen=$(lsblk -d -o NAME,RM,SIZE,MODEL -nr 2>/dev/null \
        | awk '$2==1 {printf "%s (%s, %s)\n", $1, $3, $4}' \
        | rofi -dmenu -p "Remove device:" 2>/dev/null)

    if [ -n "$chosen" ]; then
        dev=$(echo "$chosen" | awk '{print $1}')

        # Unmount all mounted partitions of that device
        for part in $(lsblk -ln /dev/$dev -o NAME,MOUNTPOINT 2>/dev/null | awk '$2!="" {print $1}'); do
            udisksctl unmount -b /dev/$part >/dev/null 2>&1
        done

        # Power off the whole device
        if udisksctl power-off -b /dev/$dev >/dev/null 2>&1; then
            notify-send "Drive /dev/$dev safely removed" >/dev/null 2>&1
        else
            notify-send "Failed to power off /dev/$dev" >/dev/null 2>&1
        fi
    fi
    exit 0
fi


# Collect removable parent devices
devices=$(lsblk -d -o NAME,RM -nr 2>/dev/null | awk '$2==1 {print $1}')

if [ -z "$devices" ]; then
    echo '{"text":" ","tooltip":"No external drives","class":"no-drives"}'
    exit 0
fi

display=""
tooltip=""
for dev in $devices; do
    # Check if any partition of this device is mounted
    parts=$(lsblk -ln /dev/$dev -o NAME,MOUNTPOINT 2>/dev/null | awk '$2!="" {print $1 ":" $2}')
    if [ -n "$parts" ]; then
        display="$display $dev"
        # Escape for JSON: newlines → \n, quotes → \"
        partinfo=$(echo "$parts" | sed ':a;N;$!ba;s/\n/\\n/g; s/"/\\"/g')
        tooltip="$tooltip Device: $dev\\n$partinfo\\n"
    fi
done

if [ -z "$display" ]; then
    echo '{"text":" ","tooltip":"No mounted external drives","class":"no-drives"}'
    exit 0
fi

# Output JSON only
echo "{\"text\":\" $display \",\"tooltip\":\"$tooltip\",\"class\":\"drives\"}"

