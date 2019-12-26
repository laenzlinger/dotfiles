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
bash dot_config/pacman/executable_install.sh
exit

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k


# Vim Plug (afterwards run :PlugInsall in nvim)
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


chezmoi apply
```

### List of installed packages
chezmoi apply creates list of installed packags in `.config/pacman/*.txt`
