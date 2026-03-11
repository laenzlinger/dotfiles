#!/usr/bin/env bash
set -uo pipefail

OUTPUTS=$(swaymsg -t get_outputs | jq -r '[.[] | select(.active)] | length')
EXT=$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | select(.name != "eDP-1") | .name' | head -1)

if [ "$OUTPUTS" -gt 1 ] && [ -n "$EXT" ]; then
    # Move workspaces to their assigned outputs
    for ws in 1 2 3 4 5 6 7; do
        swaymsg "workspace $ws, move workspace to output $EXT" 2>/dev/null || true
    done
    for ws in 8 9 10; do
        swaymsg "workspace $ws, move workspace to output eDP-1" 2>/dev/null || true
    done
    swaymsg focus output "$EXT" 2>/dev/null || true
    swaync-client --change-cc-monitor "$EXT" 2>/dev/null || true
    swaync-client --change-noti-monitor "$EXT" 2>/dev/null || true
else
    swaync-client --change-cc-monitor "eDP-1" 2>/dev/null || true
    swaync-client --change-noti-monitor "eDP-1" 2>/dev/null || true
fi

# Reload waybar with correct config
~/.config/waybar/scripts/waybar-reload.sh
