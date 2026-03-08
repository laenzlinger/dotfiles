#!/usr/bin/env bash
set -euo pipefail
USAGE=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.0f", usage}')
LOAD=$(cut -d' ' -f1-3 < /proc/loadavg)
CORES=$(nproc)
TOP=$(ps -eo comm,%cpu --sort=-%cpu | head -8 | tail -7 | awk 'NR>1{printf "\\n"}{printf "%s: %s%%", $1, $2}')

CLASS=""
if [ "$USAGE" -ge 85 ]; then
  CLASS="critical"
elif [ "$USAGE" -ge 60 ]; then
  CLASS="warning"
fi

printf '{"text": "󰻠 %s%%", "class": "%s", "tooltip": "Load: %s (%s cores)\\n\\n%s"}\n' "$USAGE" "$CLASS" "$LOAD" "$CORES" "$TOP"
