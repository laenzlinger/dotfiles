#!/usr/bin/env bash
USAGE=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.0f", usage}')
LOAD=$(cut -d' ' -f1-3 < /proc/loadavg)
CORES=$(nproc)
TOP=$(ps -eo comm,%cpu --sort=-%cpu | head -8 | tail -7 | awk 'NR>1{printf "\\n"}{printf "%s: %s%%", $1, $2}')
printf '{"text": "󰻠 %s%%", "tooltip": "Load: %s (%s cores)\\n\\n%s"}\n' "$USAGE" "$LOAD" "$CORES" "$TOP"
