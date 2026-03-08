#!/usr/bin/env bash
set -euo pipefail
command -v wpctl >/dev/null || exit 1
wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f\n", $2 * 100}'
