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

See [arch/INSTALLATION_GUIDE.md](arch/INSTALLATION_GUIDE.md) for bare metal, or:

```bash
loadkeys de_CH-latin1
curl https://raw.githubusercontent.com/laenzlinger/dotfiles/master/arch/setup-vmware.sh > setup-vmware.sh
bash setup-vmware.sh
```

### User setup (all platforms)

```bash
chezmoi init https://github.com/laenzlinger/dotfiles.git
chezmoi cd
# then run the platform setup script:
#   arch/setup-user.sh
#   darwin/setup-user.sh
#   debian/setup-user.sh
```

### Create user (Arch)

```bash
arch-chroot /dev
passwd
useradd -m <username>
passwd <username>
visudo                  # <username>   ALL=(ALL) ALL
```

### Testing in Docker

See [arch/Makefile](arch/Makefile)

### Installed packages

`chezmoi apply` creates list of installed packages in [.config/pacman/*.txt](dot_config/pacman)

## Documentation

- [Zsh](docs/zsh.md) — shell config, plugins, performance
- [Environment Variables](docs/environment-variables.md) — session-wide env setup
- [Systemd Units](docs/systemd.md) — background daemons
- [GPG](docs/gpg.md) — key management
- [Troubleshooting](docs/troubleshooting.md) — common issues
- [TODO](docs/todo.md) — open items
- [ADR 001](docs/adr/001-migrate-from-oh-my-zsh-to-antidote.md) — oh-my-zsh → antidote migration
