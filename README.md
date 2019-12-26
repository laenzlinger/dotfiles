# Configuration of my devbox

This repo contains the dotfiles managed by chezmoi

## Arch Linux (on VMWare Fusion)

### Manual steps

Followed steps in Arch Linux [installation guide](https://wiki.archlinux.org/index.php/installation_guide)

VM Settings:
* UEFI boot mode (set firmware = "efi" in VMX file)
* Virtual Disk Size 50GB
* 4 CPU
* 4096 MB RAM


### Run the installation script
```bash
loadkeys de_CH-latin1
curl https://raw.githubusercontent.com/laenzlinger/dotfiles/master/arch/setup.sh > setup.sh
chmod u+x setup.sh
./setup.sh
```

### Create user

```bash
arch-chroot /dev
passwd
adduser -m laenzi
passwd laenzi
visudo                  # laenzi   ALL=(ALL) ALL
```

### Install all packages

### chezmoi apply

```bash
chezmoi init https://github.com/laenzlinger/dotfiles.git
chezmoi cd
install.sh
exit
chezmoi apply
```

### List of installed packages
chezmoi apply creates list of installed packags in `.config/pacman/*.txt`
