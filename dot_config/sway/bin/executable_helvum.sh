#!/usr/bin/env bash
set -euo pipefail
command -v helvum >/dev/null || { notify-send "Helvum not installed"; exit 1; }
if swaymsg -t get_tree | jq -e '.. | select(.app_id? == "org.pipewire.Helvum" and .visible == true)' > /dev/null; then
    swaymsg '[app_id="org.pipewire.Helvum"] kill'
else
    helvum
fi
