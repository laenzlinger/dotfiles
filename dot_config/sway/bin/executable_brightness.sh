#!/usr/bin/env bash

brightnessctl -m | cut -d, -f4 | tr -d %
