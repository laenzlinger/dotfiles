#!/usr/bin/env bash
USAGE=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.0f", usage}')
TOP=$(ps -eo comm,%cpu --sort=-%cpu | head -8 | tail -7 | awk 'NR>1{printf "\\n"}{printf "%s: %s%%", $1, $2}')
printf '{"text": "  %s%%", "tooltip": "Top processes:\\n%s"}\n' "$USAGE" "$TOP"
