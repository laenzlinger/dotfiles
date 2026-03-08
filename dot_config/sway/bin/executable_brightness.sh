#!/usr/bin/env bash
set -euo pipefail
command -v brightnessctl >/dev/null || exit 1
echo "$(brightnessctl -m | cut -d, -f4 | tr -d %) BRIGHTNESS"
