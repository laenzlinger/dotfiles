#!/usr/bin/env bash
set -euo pipefail

STATUS_FILE="$HOME/.cache/resticprofile/status.json"
ONE_DAY_SEC=86400

ICON_OK=󰪩
ICON_STALE=󱘪
ICON_ERROR=󱘤
ICON_UNKNOWN=󰴀
ICON_RUNNING=󰗂

mkdir -p "$(dirname "$STATUS_FILE")"

if pgrep -x "restic" >/dev/null; then
  echo "{\"text\": \"$ICON_RUNNING\", \"class\": \"running\", \"tooltip\": \"Backup currently active...\"}"
  exit 0
fi

if [ ! -f "$STATUS_FILE" ]; then
  echo "{\"text\": \"$ICON_UNKNOWN\", \"class\": \"unknown\", \"tooltip\": \"No backup history found\"}"
  exit 0
fi

profiles=$(jq -r '.profiles | keys[] | select(endswith("-term") | not)' "$STATUS_FILE" 2>/dev/null)
if [ -z "$profiles" ]; then
  echo "{\"text\": \"$ICON_UNKNOWN\", \"class\": \"unknown\", \"tooltip\": \"Status file is empty or invalid\"}"
  exit 0
fi

NOW=$(date +%s)
worst="ok"
tooltip=""

for profile in $profiles; do
  success=$(jq -r ".profiles.\"$profile\".backup.success" "$STATUS_FILE")
  time_raw=$(jq -r ".profiles.\"$profile\".backup.time" "$STATUS_FILE")
  last_sec=$(date -d "$time_raw" +%s 2>/dev/null || echo 0)
  age=$((NOW - last_sec))

  if [ "$success" != "true" ]; then
    status="❌"
    [ "$worst" != "error" ] && worst="error"
  elif [ "$age" -gt "$ONE_DAY_SEC" ]; then
    days=$((age / ONE_DAY_SEC))
    status="⚠ ${days}d ago"
    [ "$worst" = "ok" ] && worst="warning"
  else
    status="✓"
  fi

  time_fmt=$(date -d "$time_raw" "+%m-%d %H:%M" 2>/dev/null || echo "unknown")
  tooltip="${tooltip}${profile}: ${status} (${time_fmt})\\n"
done

case "$worst" in
  error)    icon="$ICON_ERROR";   class="error" ;;
  warning)  icon="$ICON_STALE";   class="warning" ;;
  *)        icon="$ICON_OK";      class="ok" ;;
esac

printf '{"text": "%s", "class": "%s", "tooltip": "%s"}\n' "$icon" "$class" "${tooltip%\\n}"
