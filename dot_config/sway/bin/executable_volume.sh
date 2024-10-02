#!/usr/bin/env bash

wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' | awk '{print "scale=0;"$1"*10000/100"}' | bc
