#!/usr/bin/env sh

######################################################################
# @file        : apply-tinty-theme
# @created     : Saturday May 04, 2024 17:20:13 CEST
#
# @description : apply the tinty managed colors to iterm2 config
######################################################################


/usr/libexec/PlistBuddy \
    -c 'Delete "tinty-managed"' \
    -c 'Add "tinty-managed" dict' \
    -c "Merge ""$HOME/.config/iterm2/tinty-managed.itermcolors"" ""tinty-managed""" $HOME/.config/iterm2/com.googlecode.iterm2.plist
