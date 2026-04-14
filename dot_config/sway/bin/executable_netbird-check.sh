#!/usr/bin/env bash
set -euo pipefail

command -v netbird >/dev/null

NID=(-h string:x-canonical-private-synchronous:netbird-auth)
NOTIFIED=false

while true; do
    sleep 300
    mgmt=$(netbird status 2>/dev/null | grep "^Management:" | awk '{print $2}' || true)
    if [[ "$mgmt" == "Connected" ]]; then
        NOTIFIED=false
    elif [[ "$mgmt" != "" && "$NOTIFIED" == false ]]; then
        notify-send -u critical "${NID[@]}" "󰒃   Netbird VPN" "Session expired — re-login required"
        NOTIFIED=true
    fi
done
