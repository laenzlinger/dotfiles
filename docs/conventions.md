# Conventions

Guiding principles for this dotfiles repository.

## Package management

- Prefer official Arch repos (`core`, `extra`) over AUR whenever possible
- AUR packages are acceptable when no official alternative exists
- Document AUR dependencies explicitly when used

## Configuration

- Follow XDG Base Directory specification
- Manage dotfiles with chezmoi
- Keep configurations minimal and auditable

## Systemd

- Use systemd user services for session daemons
- Depend on `graphical-session.target` for desktop services
- Use UWSM for Wayland session lifecycle management

## Documentation

- Record significant decisions as ADRs in `docs/adr/`
- Keep docs close to what they describe

## Scripts

- `#!/usr/bin/env bash` + `set -euo pipefail` + `command -v` checks
- Pre-commit hooks enforce shellcheck — fix warnings before committing
- Monospace font: MesloLGS Nerd Font (for calendar, code, terminals)

## Theming

- Tinty hooks: New apps need a tinty item in config.toml.tmpl to auto-theme
- Color generation: Derive app colors from waybar colors.css (rofi, swaync, wob, obsidian, vivaldi)
- Dark/light: Darkman switches tinty schemes (darktooth/gruvbox-light-medium)
- Sway reload: Not triggered on theme switch (causes ~30s waybar restart); border colors update on manual reload
- Tray icons: Monochrome (blueman symbolic, keepassxc monochrome-dark)

## Workflow

1. Edit files in `~/.local/share/chezmoi/`
2. Apply individual files with `chezmoi apply <path>` (not full apply)
3. Test the change
4. **Update cheatsheet** if keybindings or user-facing behavior changed
5. **After testing**: review all uncommitted changes with `git status`/`git diff`, group into logical commits with descriptive messages, and push to GitHub
