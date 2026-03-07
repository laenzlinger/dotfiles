#!/usr/bin/env bash
if swaymsg -t get_tree | jq -e '.. | select(.app_id? == "blueman-manager" and .visible == true)' > /dev/null; then
    swaymsg '[app_id="blueman-manager"] kill'
else
    blueman-manager
fi
