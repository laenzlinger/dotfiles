#!/bin/bash

# Check if the device file exists
if [ ! -e "/dev/microscope" ]; then
  # Send a desktop notification using notify-send
  notify-send "Microscope Error" "/dev/microscope not found. Please check connection."
  exit 1
fi

ffplay -f v4l2 -video_size 1920x1080 /dev/microscope
