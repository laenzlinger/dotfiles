#!/usr/bin/env bash
# Auto-mount USB devices and notify.
while sleep 2; do
    lsblk -Jpo NAME,MOUNTPOINT,HOTPLUG,TYPE 2>/dev/null |
        jq -r '.blockdevices[] | .. | select(.type?=="part" and .hotplug?==true and .mountpoint==null) | .name' 2>/dev/null |
        while read -r dev; do
            if msg=$(udisksctl mount -b "$dev" --no-user-interaction 2>&1); then
                mp=$(echo "$msg" | grep -oP 'at \K.*')
                notify-send "USB Mounted" "$mp"
            fi
        done || true
done
