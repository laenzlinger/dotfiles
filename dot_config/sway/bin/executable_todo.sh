#!/usr/bin/env bash
set -euo pipefail
APP_ID="todo-nvim"
if swaymsg -t get_tree | jq -e ".. | select(.app_id? == \"$APP_ID\")" > /dev/null 2>&1; then
    swaymsg "[app_id=\"$APP_ID\"] scratchpad show"
else
    foot --app-id="$APP_ID" --window-size-chars=120x50 nvim ~/notes/gtd/TODO.md
fi
