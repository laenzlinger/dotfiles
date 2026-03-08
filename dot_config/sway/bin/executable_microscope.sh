#!/usr/bin/env bash
set -euo pipefail
if [ ! -e "/dev/microscope" ]; then
    notify-send "Microscope Error" "/dev/microscope not found. Please check connection."
    exit 1
fi
ffplay -f v4l2 -video_size 1920x1080 /dev/microscope
