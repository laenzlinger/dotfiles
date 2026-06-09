#!/usr/bin/env bash
set -euo pipefail
APP_ID="todo-nvim"
if swaymsg -t get_tree | jq -e ".. | select(.app_id? == \"$APP_ID\" and .visible == true)" > /dev/null; then
    swaymsg "[app_id=\"$APP_ID\"] kill"
else
    foot --app-id="$APP_ID" --window-size-chars=150x50 nvim ~/notes/gtd/TODO.md
fi
