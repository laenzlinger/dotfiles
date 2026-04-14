#!/usr/bin/env bash
set -euo pipefail
command -v wpctl >/dev/null || exit 1

case "${1:-}" in
    up)   wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
          if [ "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2 * 100}')" = "0" ]; then
              wpctl set-mute @DEFAULT_AUDIO_SINK@ 1
          fi ;;
    mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
esac

vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
level=$(echo "$vol" | awk '{printf "%.0f", $2 * 100}')
if echo "$vol" | grep -q MUTED; then
    echo "$level MUTED"
else
    echo "$level"
fi
