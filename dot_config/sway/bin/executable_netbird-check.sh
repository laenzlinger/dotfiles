#!/usr/bin/env bash
set -euo pipefail

command -v netbird >/dev/null

check() {
    sleep 15
    for _ in 1 2 3; do
        local mgmt
        mgmt=$(netbird status 2>/dev/null | grep "^Management:" | awk '{print $2}' || true)
        [[ "$mgmt" == "Connected" ]] && return
        sleep 10
    done
    notify-send \
        -u critical \
        -h string:x-canonical-private-synchronous:netbird-auth \
        "󰒃   Netbird VPN" \
        "Session expired — re-login required"
}

check &

nmcli monitor | while read -r line; do
    if [[ "$line" == *"Connectivity is now"*"full"* ]]; then
        check &
    fi
done
