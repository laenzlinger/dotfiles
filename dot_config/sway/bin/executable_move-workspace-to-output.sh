#!/bin/bash

OUTPUT=$1

# workspace
swaymsg [workspace="1"] move workspace to output "$OUTPUT"
swaymsg [workspace="2"] move workspace to output "$OUTPUT"
swaymsg [workspace="3"] move workspace to output "$OUTPUT"
swaymsg [workspace="4"] move workspace to output "$OUTPUT"
swaymsg [workspace="5"] move workspace to output "$OUTPUT"

# waybar
CONFIG=~/.config/waybar/config.jsonc
sed -i "s/\"output\": \".*\"/\"output\": \"$OUTPUT\"/" "$CONFIG"
killall waybar && waybar &

# notification
swaync-client --change-cc-monitor "$OUTPUT"
swaync-client --change-noti-monitor "$OUTPUT"
