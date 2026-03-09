#!/usr/bin/env bash
set -euo pipefail
APP=$1; APP_ID=$2
command -v "$APP" >/dev/null || { notify-send "$APP not installed"; exit 1; }
if swaymsg -t get_tree | jq -e ".. | select(.app_id? == \"$APP_ID\" and .visible == true)" > /dev/null; then
    swaymsg "[app_id=\"$APP_ID\"] kill"
else
    "$APP"
fi
