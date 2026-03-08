#!/usr/bin/env bash
set -euo pipefail
command -v nm-connection-editor >/dev/null || { notify-send "nm-connection-editor not installed"; exit 1; }
if swaymsg -t get_tree | jq -e '.. | select(.app_id? == "nm-connection-editor" and .visible == true)' > /dev/null; then
    swaymsg '[app_id="nm-connection-editor"] kill'
else
    nm-connection-editor
fi
