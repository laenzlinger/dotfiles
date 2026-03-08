#!/usr/bin/env bash
read -r TOTAL AVAIL <<< "$(grep -E "MemTotal|MemAvailable" /proc/meminfo | awk '{print $2}' | tr '\n' ' ')"
USED=$(( (TOTAL - AVAIL) / 1024 ))
TOTAL_MB=$((TOTAL / 1024))
PCT=$(( USED * 100 / TOTAL_MB ))
TOP=$(ps -eo comm,%mem --sort=-%mem | head -8 | tail -7 | awk 'NR>1{printf "\\n"}{printf "%s: %s%%", $1, $2}')

CLASS=""
if [ "$PCT" -ge 85 ]; then
  CLASS="critical"
elif [ "$PCT" -ge 70 ]; then
  CLASS="warning"
fi

printf '{"text": "󰍛 %s%%", "class": "%s", "tooltip": "Used: %sMB / %sMB\\n\\n%s"}\n' "$PCT" "$CLASS" "$USED" "$TOTAL_MB" "$TOP"
