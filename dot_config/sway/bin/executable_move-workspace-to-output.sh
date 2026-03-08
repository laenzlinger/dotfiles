#!/usr/bin/env bash
set -euo pipefail
OUTPUT="$1"

swaymsg focus output "$OUTPUT"

for ws in $(seq 1 9); do
    swaymsg "[workspace=\"$ws\"] move workspace to output \"$OUTPUT\""
done

CONFIG=~/.config/waybar/config.jsonc
sed -i "s/\"output\": \".*\"/\"output\": \"$OUTPUT\"/" "$CONFIG"
killall waybar && waybar &

swaync-client --change-cc-monitor "$OUTPUT"
swaync-client --change-noti-monitor "$OUTPUT"
