#!/usr/bin/env bash
set -euo pipefail
command -v swaymsg >/dev/null || exit 1
command -v jq >/dev/null || exit 1

EXT=$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | select(.name != "eDP-1") | .name' | head -1)

LID=$(awk '{print $2}' /proc/acpi/button/lid/*/state 2>/dev/null || true)

case "${1:-}" in
    close)
        if [ -n "$EXT" ]; then
            swaymsg output eDP-1 disable
            ~/.config/sway/bin/move-workspace-to-output.sh
            ~/.config/waybar/scripts/waybar-reload.sh
        fi
        ;;
    open)
        swaymsg output eDP-1 enable
        ~/.config/sway/bin/move-workspace-to-output.sh
        ~/.config/waybar/scripts/waybar-reload.sh
        ;;
    check)
        if [ "$LID" = "closed" ] && [ -n "$EXT" ]; then
            swaymsg output eDP-1 disable
        fi
        ;;
esac
