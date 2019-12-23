# Configuration of my devbox

This repo contains the dotfiles managed by chezmoi

## List installed packages

```
pacman -Qqen > pkglist.pacman
```

## Install all packages


```
pacman -S - < pkglist.pacman
```
