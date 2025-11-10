#!/usr/bin/env sh

######################################################################
# @file        : tinty.sh
# @created     : Saturday Apr 27, 2024 16:32:42 CEST
#
# @description : set tinty theme to dark or lignt mode (called by darkman)
######################################################################

case "$1" in
dark) THEME=base16-darktooth ;;
light) THEME=base16-solarized-light ;;
esac

/usr/bin/tinty apply "$THEME"
