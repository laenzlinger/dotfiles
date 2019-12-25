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


```
loadkeys de_CH-latin1
```

Create partitions with `fdisk`. Create a GPT partition tablef

```
fdisk -l
TODO
```

Format partitions

```
# EFI partiation
mkfs.fat -F32 /dev/sda1
# Root / partition
mkfs.ext4 /dev/sda2
# Swap
mkswap /dev/sda3
swapon /dev/sda3
```

Mount the file systems

```
mount /dev/sda2 /mnt
mkdir /mnt/efi
mount /dev/sda1 /mnt/efi
```

Install base system

```
pacstrap /mnt base linux linux-firmware vi dhcpcd grub efibootmgr
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime
vi /etc/locale.gen     # uncomment en_US.UTF-8 and de-CH.UTF-8
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=de_CH-latin1" > /etc/vconsole.conf
echo arch > /etc/hostname
vi /etc/hosts          # see installation guid
systemctl enable dhcpcd.service
passwd
```

Install grub

```
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

### Create user

```
useradd -m laenzi
passwd
pacman -S git sudo
visudo                  # laenzi   ALL=(ALL) ALL
```

### Install all packages
To install all the packages `git clone` run `bash dot_config/pacman/executable_install.sh` or (once installed `.config/pacman/install.sh`


```
vi /etc/mkinitcpio.conf  # MODULES=(... vmhgfs,vmxnet)
sudo systemctl enable vmtoolsd.service
sudo systemctl enable vmware-vmblock-fuse.service
```

### Xorg Keyboard

```
sudo cat /etc/X11/xorg.conf.d/00-keyboard.conf                    ─╯
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "ch"
        Option "XkbModel" "macintosh"
        Option "XkbVariant" "de"
EndSection
```

### chezmoi apply

```
chezmoi init https://github.com/laenzlinger/dotfiles.git

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

chezmoi apply
```

### List of installed packages
chezmoi apply creates list of installed packags in `.config/pacman/*.txt`
