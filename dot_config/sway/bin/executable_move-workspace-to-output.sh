#!/usr/bin/env bash
set -uo pipefail
OUTPUT="$1"

# Move all workspaces to target output (may fail during output transitions)
swaymsg -t get_workspaces | jq -r '.[].name' | while read -r ws; do
    swaymsg "workspace $ws, move workspace to output $OUTPUT" 2>/dev/null || true
done
swaymsg focus output "$OUTPUT" 2>/dev/null || true

# Update waybar config and restart
sed -i "s/\"output\": \".*\"/\"output\": \"$OUTPUT\"/" ~/.config/waybar/config.jsonc
killall -q waybar || true
swaymsg exec waybar

# Move notification center
swaync-client --change-cc-monitor "$OUTPUT"
swaync-client --change-noti-monitor "$OUTPUT"
