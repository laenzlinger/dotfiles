#!/usr/bin/env bash
set -euo pipefail

command -v checkupdates >/dev/null || { echo '{"text": "", "class": "", "tooltip": "checkupdates not found"}'; exit 0; }

updates=$(checkupdates 2>/dev/null || true)
count=$(echo -n "$updates" | grep -c '^' || true)

if [ "$count" -eq 0 ]; then
  echo '{"text": "", "class": "", "tooltip": "System is up to date"}'
  exit 0
fi

list=$(echo "$updates" | head -20 | awk '{printf "%s: %s → %s\\n", $1, $2, $4}')
[ "$count" -gt 20 ] && list="${list}\\n... and $((count - 20)) more"

class="warning"
[ "$count" -ge 50 ] && class="critical"

printf '{"text": "󰏔 %s", "class": "%s", "tooltip": "%s update(s)\\n\\n%s"}\n' "$count" "$class" "$count" "$list"
