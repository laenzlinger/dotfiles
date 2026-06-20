#!/usr/bin/env bash
set -euo pipefail

STATUS_FILE="$HOME/.cache/resticprofile/status.json"
ONE_DAY_SEC=86400
THREE_DAYS_SEC=259200
FIVE_DAYS_SEC=432000
SEVEN_DAYS_SEC=604800

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
  else
    # Relaxed thresholds for homeoffice
    if [[ "$profile" == *homeoffice* ]]; then
      warn_sec=$FIVE_DAYS_SEC
      err_sec=$SEVEN_DAYS_SEC
    else
      warn_sec=$ONE_DAY_SEC
      err_sec=$THREE_DAYS_SEC
    fi

    if [ "$age" -gt "$err_sec" ]; then
      days=$((age / ONE_DAY_SEC))
      status="❌ ${days}d ago"
      worst="error"
    elif [ "$age" -gt "$warn_sec" ]; then
      days=$((age / ONE_DAY_SEC))
      status="⚠ ${days}d ago"
      [ "$worst" = "ok" ] && worst="warning"
    else
      status="✓"
    fi
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
