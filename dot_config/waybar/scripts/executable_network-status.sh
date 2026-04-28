#!/usr/bin/env bash
set -euo pipefail

# Network info
WIFI=$(nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2,3 || true)
if [ -n "$WIFI" ]; then
    SSID=$(echo "$WIFI" | cut -d: -f1)
    SIGNAL=$(echo "$WIFI" | cut -d: -f2)
    IFACE=$(nmcli -t -f device,type dev | grep ':wifi$' | cut -d: -f1 | head -1)
    IP=$(ip -4 addr show "$IFACE" 2>/dev/null | grep inet | awk '{print $2}')
    GW=$(ip route | grep default | awk '{print $3}' | head -1)
    if [ "$SIGNAL" -ge 75 ]; then ICON="󰤥"
    elif [ "$SIGNAL" -ge 50 ]; then ICON="󰤢"
    elif [ "$SIGNAL" -ge 25 ]; then ICON="󰤟"
    else ICON="󰤯"; fi
    NET_TEXT="$ICON  $SSID"
    NET_TIP="$SSID ($SIGNAL%)\n$IP\nGateway: $GW"
else
    CONN_INFO=$(nmcli -t -f name,device,type con show --active 2>/dev/null | grep -vE ':(loopback|wireguard)$' | head -1 || true)
    if [ -n "$CONN_INFO" ]; then
        CONN=$(echo "$CONN_INFO" | cut -d: -f1)
        IFACE=$(echo "$CONN_INFO" | cut -d: -f2)
        IP=$(ip -4 addr show "$IFACE" 2>/dev/null | grep inet | awk '{print $2}')
        GW=$(ip route | grep default | awk '{print $3}' | head -1)
        NET_TEXT="󰄜 ${CONN}"
        NET_TIP="${CONN}\n$IP\nGateway: $GW"
    else
        NET_TEXT="󰤭  Down"
        NET_TIP="Network disconnected"
    fi
fi

# VPN info
NB_STATUS=$(netbird status 2>/dev/null || true)
NB_MGMT=$(echo "$NB_STATUS" | grep "^Management:" | cut -d' ' -f2 || true)
NB_IP=$(echo "$NB_STATUS" | grep "^NetBird IP:" | cut -d' ' -f3 || true)

if [ "$NB_MGMT" = "Connected" ]; then
    NET_TEXT="$NET_TEXT 󰒄"
    NET_TIP="$NET_TIP\nVPN: $NB_IP"
fi

# WiFi radio status
if [ "$(nmcli radio wifi 2>/dev/null)" = "disabled" ]; then
    NET_TEXT="$NET_TEXT 󰀝"
    NET_TIP="$NET_TIP\nWiFi radio: off"
fi

printf '{"text": "%s", "tooltip": "%s"}\n' "$NET_TEXT" "$NET_TIP"
