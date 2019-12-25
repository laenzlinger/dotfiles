#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pacman -Qqen > $DIR/pkglist.txt
pacman -Qqem > $DIR/foreignpkglist.txt
echo "#optional dependencies" > $DIR/optdeplist.txt
comm -13 <(pacman -Qqdt | sort) <(pacman -Qqdtt | sort) >> $DIR/optdeplist.txt
