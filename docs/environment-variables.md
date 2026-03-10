# Environment Variables

Session-wide environment variables live in `~/.config/environment.d/*.conf`.

## How it works

- **Linux**: systemd reads these files natively via `systemd-environment-d-generator`.
  The display manager (ly) sources `~/.config/zsh/.zprofile`, which runs the same
  generator to import these variables into the login session — making them available
  to sway, waybar, rofi, terminals, and all child processes.
- **macOS**: `.zshrc` sources them with `set -a; source; set +a`

This gives a single source of truth for both platforms.

## Files

- `path.conf` — PATH additions (`~/.local/bin`, `~/.cargo/bin`, Go bin)
- `defaults.conf` — LANG, EDITOR, ZDOTDIR
- `gpg.conf` — SSH_AUTH_SOCK for GPG agent SSH support
- `qt-theme.conf` — Qt theme integration

## Why not .zshrc?

Environment variables set in `.zshrc` are only available in interactive shells.
`environment.d` provides them to the entire session — sway, GUI apps, and shells alike.
On Linux, `.zprofile` imports them at login via `systemd-environment-d-generator`.

## Adding new variables

1. Add to the appropriate `.conf` file in `dot_config/environment.d/`
2. `chezmoi apply ~/.config/environment.d/`
3. Log out and back in for changes to take effect
