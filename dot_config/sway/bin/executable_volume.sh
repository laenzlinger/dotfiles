#!/usr/bin/env bash
set -euo pipefail
command -v wpctl >/dev/null || exit 1
vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
level=$(echo "$vol" | awk '{printf "%.0f", $2 * 100}')
if echo "$vol" | grep -q MUTED; then
    echo "$level MUTED"
else
    echo "$level"
fi
