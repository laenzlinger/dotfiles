# Environment Variables

Session-wide environment variables live in `~/.config/environment.d/*.conf`.

## How it works

- **Linux**: systemd reads these files natively at login (before sway starts)
- **macOS**: `.zshrc` sources them with `set -a; source; set +a`

This gives a single source of truth for both platforms.

## Files

- `path.conf` — PATH additions (`~/.local/bin`, `~/.cargo/bin`, Go bin)
- `defaults.conf` — LANG, EDITOR
- `qt-theme.conf` — Qt theme integration

## Why not .zshrc?

Environment variables set in `.zshrc` are only available in interactive shells.
On Linux, sway is launched by the display manager (ly), not through a login shell,
so `.zshrc` exports aren't inherited by sway, rofi, waybar, or GUI apps.

`environment.d` is loaded by systemd before the session starts, making vars
available everywhere.

## Adding new variables

1. Add to the appropriate `.conf` file in `dot_config/environment.d/`
2. `chezmoi apply ~/.config/environment.d/`
3. Log out and back in for changes to take effect
