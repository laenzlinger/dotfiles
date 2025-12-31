#!/bin/bash

# Usage: ./unsplash_random.sh "search terms"
# Requires: curl, jq, UNSPLASH_ACCESS_KEY env variable

if [ -z "$UNSPLASH_ACCESS_KEY" ]; then
  echo "Set UNSPLASH_ACCESS_KEY environment variable with your Unsplash API key."
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "Usage: $0 \"search terms\""
  exit 1
fi

QUERY=$(echo "$*" | sed 's/ /%20/g')
API_URL="https://api.unsplash.com/photos/random?query=$QUERY&client_id=$UNSPLASH_ACCESS_KEY"

IMAGE_URL=$(curl -s "$API_URL" | jq -r '.urls.full')

if [ "$IMAGE_URL" = "null" ]; then
  echo "No image found for: $*"
  exit 1
fi

curl -L "$IMAGE_URL" -o "$HOME/.config/sway/resources/background.jpg"

# Reload sway configuration
swaymsg reload
