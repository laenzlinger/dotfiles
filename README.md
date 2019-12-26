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


```bash
loadkeys de_CH-latin1
```

Create partitions with `fdisk`. Create a GPT partition tablef

```
cat sfdisk.dump                                                                                                 
label: gpt
label-id: C8F7AF60-8368-9643-AD1C-85CFE21890F3
device: /dev/sda
unit: sectors
first-lba: 2048
last-lba: 104857566

/dev/sda1 : start=        2048, size=     1048576, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, uuid=DE315412-076D-BE41-BEA0-1E7E6D513038
/dev/sda2 : start=     1050624, size=    94371840, type=4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709, uuid=044839E9-2B3C-BA4E-8301-741D88FB2CEA
/dev/sda3 : start=    95422464, size=     9435103, type=0657FD6D-A4AB-43C4-84E5-0933C84B4F4F, uuid=BF769C53-979D-7E40-87C8-5E45426F43AF
```

Format partitions

```bash
# EFI partiation
mkfs.fat -F32 /dev/sda1
# Root / partition
mkfs.ext4 /dev/sda2
# Swap
mkswap /dev/sda3
swapon /dev/sda3
```

Mount the file systems

```bash
mount /dev/sda2 /mnt
mkdir /mnt/efi
mount /dev/sda1 /mnt/efi
```

Install base system

```bash
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

```bash
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

### Create user

```bash
useradd -m laenzi
passwd
pacman -S git sudo
visudo                  # laenzi   ALL=(ALL) ALL
```

### Install all packages
To install all the packages `git clone` run `bash dot_config/pacman/executable_install.sh` or (once installed `.config/pacman/install.sh`


```bash
vi /etc/mkinitcpio.conf  # MODULES=(... vmhgfs,vmxnet)
sudo systemctl enable vmtoolsd.service
sudo systemctl enable vmware-vmblock-fuse.service
```

### Xorg Keyboard

```bash
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

```bash
chezmoi init https://github.com/laenzlinger/dotfiles.git

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
