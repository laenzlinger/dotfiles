#!/usr/bin/env bash
set -euo pipefail

# List removable disks that have at least one mounted partition
disks=$(lsblk -Jpo NAME,MOUNTPOINT,HOTPLUG,TYPE,MODEL 2>/dev/null |
    jq -r '[.blockdevices[] | select(.hotplug==true and .type=="disk") |
        select(.children[]?.mountpoint != null)] | unique_by(.name)[] |
        "\(.name) \(.model // "USB Drive")"')
[ -n "$disks" ] || { notify-send "No removable devices mounted"; exit 0; }

choice=$(echo "$disks" | awk '{$1=""; print substr($0,2)}' | rofi -dmenu -i -p "Unmount")
[ -n "$choice" ] || exit 0

disk=$(echo "$disks" | grep "$choice" | awk '{print $1}')
# Unmount all partitions
lsblk -Jpo NAME,MOUNTPOINT,TYPE "$disk" 2>/dev/null |
    jq -r '.blockdevices[].children[]? | select(.mountpoint != null) | .name' |
    while read -r part; do
        udisksctl unmount -b "$part" 2>/dev/null
    done

# Power off the drive
if udisksctl power-off -b "$disk" 2>&1; then
    notify-send "Ejected" "$choice"
else
    notify-send "Unmounted" "$choice"
fi
