#!/usr/bin/env bash
set -euo pipefail
OUTPUT="$1"

swaymsg focus output "$OUTPUT"

for ws in $(swaymsg -t get_workspaces | jq -r '.[].name'); do
    swaymsg "[workspace=\"$ws\"] move workspace to output \"$OUTPUT\""
done

CONFIG=~/.config/waybar/config.jsonc
sed -i "s/\"output\": \".*\"/\"output\": \"$OUTPUT\"/" "$CONFIG"
killall waybar || true
swaymsg exec waybar

swaync-client --change-cc-monitor "$OUTPUT"
swaync-client --change-noti-monitor "$OUTPUT"
