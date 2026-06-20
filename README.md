# Configuration Repository

Dotfiles managed by [chezmoi](https://www.chezmoi.io/). Opinionated, personal, evolving.

## Setup

- **OS**: Arch Linux / macOS
- **WM**: Sway (Wayland)
- **Shell**: Zsh with Starship prompt
- **Terminal**: WezTerm
- **Theme**: Base16 via tinty

## Installation

### Arch Linux

See [arch/INSTALLATION_GUIDE.md](arch/INSTALLATION_GUIDE.md) for bare metal installation.

### User setup (all platforms)

```bash
# prerequisites (Arch)
sudo pacman -S chezmoi git base-devel

chezmoi init https://github.com/laenzlinger/dotfiles.git
chezmoi cd
# then run the platform setup script:
#   bash arch/setup-user.sh
```

### Create user (Arch)

```bash
arch-chroot /mnt
passwd
useradd -m -G wheel -s /bin/zsh <username>
passwd <username>
EDITOR=vim visudo   # uncomment %wheel ALL=(ALL:ALL) ALL
```

### Testing in Docker

See [arch/Makefile](arch/Makefile)

### Installed packages

`chezmoi apply` creates list of installed packages in [.config/pacman/*.txt](dot_config/pacman)

## Documentation

- [Conventions](docs/conventions.md) — guiding principles
- [Arch Linux](docs/arch.md) — hardware, system config, backups
- [Zsh](docs/zsh.md) — shell config, plugins, performance
- [Environment Variables](docs/environment-variables.md) — session-wide env setup
- [Systemd Units](docs/systemd.md) — background daemons
- [GPG](docs/gpg.md) — key management
- [Theming](docs/theming.md) — base16 colors, tinty, darkman
- [Troubleshooting](docs/troubleshooting.md) — common issues
- [TODO](docs/todo.md) — open items
- [ADR 001](docs/adr/001-migrate-from-oh-my-zsh-to-antidote.md) — oh-my-zsh → antidote migration
- [ADR 002](docs/adr/002-uwsm-for-sway-session-management.md) — UWSM for Sway session management
- [ADR 007](docs/adr/007-dns-over-tls.md) — DNS-over-TLS via systemd-resolved
- [ADR 008](docs/adr/008-network-hardening.md) — network hardening for roaming laptop
- [ADR 009](docs/adr/009-floating-preview-apps.md) — floating preview apps with vim-style navigation
