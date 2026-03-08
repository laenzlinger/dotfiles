#!/usr/bin/env bash
set -euo pipefail
command -v keepassxc >/dev/null || { notify-send "KeePassXC not installed"; exit 1; }
if swaymsg -t get_tree | jq -e '.. | select(.app_id? == "org.keepassxc.KeePassXC" and .visible == true)' > /dev/null; then
    swaymsg '[app_id="org.keepassxc.KeePassXC"] kill'
else
    keepassxc
fi
