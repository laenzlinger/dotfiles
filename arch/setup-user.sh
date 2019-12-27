#!/usr/bin/env bash


sudo pacman -S --needed - < $HOME/.local/share/chezmoi/dot_config/pacman/pkglist.txt

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k

# Vim Plug (afterwards run :PlugInsall in nvim)
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


mkdir -p $HOME/src/aur
pushd $HOME/src/aur
git clone https://aur.archlinux.org/j4-make-config-git.git
cd j4-make-config-git
makepkg -si --noconfirm
cd $HOME/src/aur
git clone https://aur.archlinux.org/nerd-fonts-meslo.git
cd nerd-fonts-meslo
makepkg -si --noconfirm
popd

echo nvim +'PlugInstall --sync' +qa
