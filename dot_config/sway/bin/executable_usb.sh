#!/usr/bin/env bash
set -euo pipefail

action=$(printf "mount\nunmount" | rofi -dmenu -i -p "USB")
[ -n "$action" ] || exit 0

if [ "$action" = "mount" ]; then
    devs=$(lsblk -rpo NAME,MOUNTPOINT,HOTPLUG,TYPE | awk '$3=="1" && $4=="part" && $2=="" {print $1}')
    [ -n "$devs" ] || { notify-send "No unmounted removable devices"; exit 0; }
    dev=$(echo "$devs" | rofi -dmenu -i -p "Mount")
    [ -n "$dev" ] || exit 0
    if msg=$(udisksctl mount -b "$dev" 2>&1); then
        notify-send "Mounted" "$msg"
    else
        notify-send "Mount failed" "$msg"
    fi
else
    devs=$(lsblk -rpo NAME,MOUNTPOINT,HOTPLUG,TYPE | awk '$3=="1" && $4=="part" && $2!="" {print $1, $2}')
    [ -n "$devs" ] || { notify-send "No mounted removable devices"; exit 0; }
    choice=$(echo "$devs" | awk '{print $2}' | rofi -dmenu -i -p "Unmount")
    [ -n "$choice" ] || exit 0
    dev=$(echo "$devs" | awk -v mp="$choice" '$2==mp {print $1}')
    if msg=$(udisksctl unmount -b "$dev" 2>&1); then
        notify-send "Unmounted" "$choice"
    else
        notify-send "Unmount failed" "$msg"
    fi
fi
