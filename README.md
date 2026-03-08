# Configuration Repository

This repo contains the dotfiles managed by `chezmoi`

It's a very of course a very opinionated and personal setup.
Together with my learning of all these great FOSS software,
also the configuration grows and evolves over time.

## TODO

### Bugs
- [x] Fix hardcoded WiFi interface `wlp0s20f3` in `waybar/scripts/network-status.sh` — auto-detect instead
- [x] Fix temperature tooltip in `waybar/config.common.jsonc` — copy-pasted from battery module
- [x] Fix typo in filename: `executable_microsope.sh` → `executable_microscope.sh`
- [x] Fix `move-workspace-to-output.sh` — uses `waymsg` (typo) instead of `swaymsg`
- [x] Fix trailing double-quote on keepassxc exec line in `sway/config`
- [x] Fix hardcoded username in `.zshrc` pipx PATH — use `$HOME` instead
- [x] Fix `Shift+Print` screenshot — properly quoted `$(...)` in sway exec

### Cleanup
- [x] Remove unused waybar arrow modules (arrow1-9 in `config.common.jsonc`)
- [x] Remove unused `vpn-status.sh` — VPN is already integrated in `network-status.sh`
- [x] Remove `config.hyprland.jsonc` — no longer using Hyprland
- [x] Remove `dot_p10k.zsh` — switched to Starship, p10k config was 96KB of dead weight
- [x] Remove powerlevel10k from `.chezmoiexternal.toml` — no longer used
- [x] Remove commented p10k source line in `.zshrc`
- [x] Remove commented `exec sway` in `.zshrc`
- [x] Remove commented Obsidian autostart in `sway/config`
- [x] Remove `dot_config/i3/` and `dot_config/i3status/` — no longer used
- [x] Remove `dot_config/termite/` — terminal emulator discontinued
- [x] Remove `dot_config/alacritty/` — replaced by WezTerm
- [x] Remove `dot_vimrc` / `dot_vim/` — fully on Neovim
- [ ] Clean up commented boilerplate in `.zshrc` (oh-my-zsh default comments)

### Improvements
- [x] Add error handling to toggle scripts (check if app is installed)
- [x] Add `$mod+Shift+a` for Helvum toggle
- [x] Add `set -euo pipefail` to toggle scripts

## Arch Linux

Followed steps in Arch Linux [installation guide](https://wiki.archlinux.org/index.php/installation_guide)

### VM: Manual steps

* UEFI boot mode
* Virtual Disk Size 50GB
* 4 CPU
* 4096 MB RAM

#### VM: Run the installation script

```bash
loadkeys de_CH-latin1
curl https://raw.githubusercontent.com/laenzlinger/dotfiles/master/arch/setup-vmware.sh > setup-vmware.sh
bash setup-vmware.sh
```

### Bare Metal steps

see [Installation Guide](/arch/INSTALLATION_GUIDE.md)

### Create user

```bash
arch-chroot /dev
passwd
useradd -m laenzi
passwd laenzi
visudo                  # laenzi   ALL=(ALL) ALL
```

### User setup

```bash
chezmoi init https://github.com/laenzlinger/dotfiles.git
chezmoi cd
arch/setup-user.sh
exit
```

### Testing in Docker

See [Makefile](arch/Makefile)

### List of installed packages

chezmoi apply creates list of installed packages in [.config/pacman/*.txt](dot_config/pacman)

## OSX

### User setup in OSX

```bash
chezmoi init https://github.com/laenzlinger/dotfiles.git
chezmoi cd
darwin/setup-user.sh
exit
```

## Debian

### User setup in Debian

```bash
curl -sfL https://git.io/chezmoi | sh
./bin/chezmoi init https://github.com/laenzlinger/dotfiles.git
.local/share/chezmoi/debian/setup-user.sh
source .zshrc
```
