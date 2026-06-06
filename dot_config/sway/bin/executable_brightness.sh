#!/usr/bin/env bash
set -euo pipefail
command -v brightnessctl >/dev/null || exit 1
pct=$(brightnessctl -m | cut -d, -f4 | tr -d %)
brightnessctl --class=leds -d '*kbd_backlight*' set "${pct}%" -q 2>/dev/null || true
WOBSOCK="${XDG_RUNTIME_DIR}/wob.sock"
[[ -p "$WOBSOCK" ]] && echo "$pct BRIGHTNESS" > "$WOBSOCK"
