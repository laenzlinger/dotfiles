#!/usr/bin/env bash
set -euo pipefail

OUTPUTS=$(swaymsg -t get_outputs | jq -r '[.[] | select(.active)] | length')

if [ "$OUTPUTS" -gt 1 ]; then
    # External + laptop: full bar on external, minimal on laptop
    ln -sf ~/.config/waybar/config-dual.jsonc ~/.config/waybar/config.jsonc
else
    # Single screen: full bar
    ln -sf ~/.config/waybar/config-single.jsonc ~/.config/waybar/config.jsonc
fi

killall -q waybar || true
swaymsg exec waybar
