#!/usr/bin/env bash
set -euo pipefail
dev="$1"
if msg=$(udisksctl mount -b "$dev" --no-user-interaction 2>&1); then
    mountpoint=$(echo "$msg" | grep -oP 'at \K.*')
    notify-send "USB Mounted" "$mountpoint"
else
    notify-send "USB Mount Failed" "$dev: $msg"
fi
