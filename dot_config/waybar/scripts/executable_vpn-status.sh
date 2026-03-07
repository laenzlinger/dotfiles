#!/usr/bin/env bash
# Get netbird status
NB_STATUS=$(netbird status 2>/dev/null)
NB_MGMT=$(echo "$NB_STATUS" | grep "^Management:" | cut -d' ' -f2)
NB_IP=$(echo "$NB_STATUS" | grep "^NetBird IP:" | cut -d' ' -f3)

if [ "$NB_MGMT" = "Connected" ]; then
    echo "{\"text\": \"󰖂\", \"class\": \"connected\", \"tooltip\": \"NetBird: $NB_IP\"}"
else
    echo "{\"text\": \"󰖂\", \"class\": \"disconnected\", \"tooltip\": \"NetBird: disconnected\"}"
fi
