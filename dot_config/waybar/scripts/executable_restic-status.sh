#!/bin/bash

# Configuration
STATUS_FILE="$HOME/.cache/resticprofile/status.json"
STATUS_DIR=$(dirname "$STATUS_FILE")
ONE_DAY_SEC=86400

# Corrected for Nerd Font v3.0+ (Meslo Nerd Font)
ICON_OK=󰪩
ICON_STALE=󱘪
ICON_ERROR=󱘤
ICON_UNKNOWN=󰴀
ICON_RUNNING=󰗂

# 1. Ensure directory exists
mkdir -p "$STATUS_DIR"

# 1. Check if restic is currently running
if pgrep -x "restic" >/dev/null; then
  echo "{\"text\": \"$ICON_RUNNING\", \"class\": \"running\", \"tooltip\": \"Backup currently active...\"}"
  exit 0
fi

# 2. Check if the status file exists
if [ ! -f "$STATUS_FILE" ]; then
  echo "{\"text\": \"$ICON_UNKNOWN\", \"class\": \"unknown\", \"tooltip\": \"No backup history found\"}"
  exit 0
fi

# 3. Get the profile name with the most recent backup timestamp
LATEST_PROFILE=$(jq -r '.profiles | to_entries | sort_by(.value.backup.time) | last | .key' "$STATUS_FILE" 2>/dev/null)

# Fallback if jq fails or file is empty
if [ -z "$LATEST_PROFILE" ] || [ "$LATEST_PROFILE" == "null" ]; then
  echo "{\"text\": \"$ICON_UNKNOWN\", \"class\": \"unknown\", \"tooltip\": \"Status file is empty or invalid\"}"
  exit 0
fi

LATEST_PROFILE=$(jq -r '.profiles | to_entries | sort_by(.value.backup.time) | last | .key' "$STATUS_FILE" 2>/dev/null)
SUCCESS=$(jq -r ".profiles.\"$LATEST_PROFILE\".backup.success" "$STATUS_FILE")
TIME_RAW=$(jq -r ".profiles.\"$LATEST_PROFILE\".backup.time" "$STATUS_FILE")

NOW=$(date +%s)
LAST_SEC=$(date -d "$TIME_RAW" +%s 2>/dev/null || echo 0)
AGE=$((NOW - LAST_SEC))
TIME_FMT=$(date -d "$TIME_RAW" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "Unknown")

if [ "$SUCCESS" != "true" ]; then
  echo "{\"text\": \"$ICON_ERROR\", \"class\": \"error\", \"tooltip\": \"FAILED: $LATEST_PROFILE\nAt: $TIME_FMT\"}"
elif [ "$AGE" -gt "$ONE_DAY_SEC" ]; then
  echo "{\"text\": \"$ICON_STALE\", \"class\": \"warning\", \"tooltip\": \"STALE (>24h): $TIME_FMT\"}"
else
  echo "{\"text\": \"$ICON_OK\", \"class\": \"ok\", \"tooltip\": \"SUCCESS: $LATEST_PROFILE\nTime: $TIME_FMT\"}"
fi
