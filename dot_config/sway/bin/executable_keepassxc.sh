#!/usr/bin/env bash
if swaymsg -t get_tree | jq -e '.. | select(.app_id? == "org.keepassxc.KeePassXC" and .visible == true)' > /dev/null; then
    swaymsg '[app_id="org.keepassxc.KeePassXC"] kill'
else
    keepassxc
fi
