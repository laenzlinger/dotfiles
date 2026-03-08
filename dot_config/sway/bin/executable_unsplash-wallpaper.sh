#!/usr/bin/env bash
set -euo pipefail
command -v curl >/dev/null || { echo "curl not found"; exit 1; }
command -v jq >/dev/null || { echo "jq not found"; exit 1; }

UNSPLASH_ACCESS_KEY=$(secret-tool lookup unsplash access-key)
[ -n "$UNSPLASH_ACCESS_KEY" ] || { echo "Set unsplash access-key in secret-tool"; exit 1; }
[ $# -gt 0 ] || { echo "Usage: $0 \"search terms\""; exit 1; }

QUERY="${*// /%20}"
IMAGE_URL=$(curl -s "https://api.unsplash.com/photos/random?query=$QUERY&client_id=$UNSPLASH_ACCESS_KEY" | jq -r '.urls.full')
[ "$IMAGE_URL" != "null" ] || { echo "No image found for: $*"; exit 1; }

curl -L "$IMAGE_URL" -o "$HOME/.config/sway/resources/background.jpg"
swaymsg reload
