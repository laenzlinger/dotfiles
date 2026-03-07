#!/usr/bin/env bash
if swaymsg -t get_tree | jq -e '.. | select(.app_id? == "nm-connection-editor" and .visible == true)' > /dev/null; then
    swaymsg '[app_id="nm-connection-editor"] kill'
else
    nm-connection-editor
fi
