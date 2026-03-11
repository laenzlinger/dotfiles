#!/usr/bin/env bash
set -uo pipefail
command -v swaymsg >/dev/null || exit 1
command -v jq >/dev/null || exit 1

WOBSOCK="${XDG_RUNTIME_DIR}/wob.sock"

last_output=""
while read -r output; do
    if [ "$output" != "$last_output" ]; then
        last_output="$output"
        echo "100 OUTPUT" > "$WOBSOCK"
    fi
done < <(swaymsg -t subscribe -m '["workspace"]' | jq --unbuffered -r '.current.output')
