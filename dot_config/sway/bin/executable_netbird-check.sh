#!/usr/bin/env bash
set -euo pipefail

command -v netbird >/dev/null

NID=(-h string:x-canonical-private-synchronous:netbird-auth)
NOTIFIED=false

while true; do
    sleep 300
    status=$(netbird status 2>/dev/null || true)
    mgmt=$(echo "$status" | grep "^Management:" | awk '{print $2}')
    ip=$(echo "$status" | grep "^NetBird IP:" | awk '{print $3}')
    if [[ "$mgmt" == "Connected" ]]; then
        NOTIFIED=false
    elif [[ "$ip" != "N/A" && "$ip" != "" && "$mgmt" != "Connected" && "$NOTIFIED" == false ]]; then
        notify-send -u critical "${NID[@]}" "󰒃   Netbird VPN" "Session expired — re-login required"
        NOTIFIED=true
    fi
done
