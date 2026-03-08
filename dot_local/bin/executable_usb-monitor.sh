#!/usr/bin/env bash
# Watch for USB mount/unmount via udisksctl monitor, send notifications.
udisksctl monitor 2>/dev/null | grep --line-buffered "MountPoints" | while read -r _; do
    sleep 1
    mounts=$(lsblk -rpo NAME,MOUNTPOINT,HOTPLUG,TYPE 2>/dev/null | awk '$3=="1" && $4=="part" && $2!="" {print $2}')
    if [ -n "$mounts" ]; then
        notify-send "USB" "$mounts"
    fi
done
