#!/usr/bin/env bash
set -euo pipefail
app_id=$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true) | .app_id')
if [[ "$app_id" != "org.keepassxc.KeePassXC" ]]; then
    clipman --notify store --no-persist
fi
