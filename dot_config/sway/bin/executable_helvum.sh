#!/usr/bin/env bash
if swaymsg -t get_tree | jq -e '.. | select(.app_id? == "org.pipewire.Helvum" and .visible == true)' > /dev/null; then
    swaymsg '[app_id="org.pipewire.Helvum"] kill'
else
    helvum
fi
