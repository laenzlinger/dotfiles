# Laenzi's Arch Linux Development Context

## System Overview
- **OS**: Arch Linux on ThinkPad X1 Carbon Gen 12
- **Window Manager**: Sway (Wayland)
- **Dotfiles**: Managed with chezmoi at `~/.local/share/chezmoi`
- **Theme**: Base16 colors via tinty (auto-switches across apps)
- **Shell**: Zsh with Starship prompt
- **Launcher**: Rofi (Wayland-native, replaced wofi)
- **Terminal**: WezTerm

## Design Preferences
- **Simple and modern** - Clean, minimal UI
- **Consistent** - Same patterns across tools
- **Functional** - Info visible without hovering when possible
- **Theme-aware** - Colors must adapt to tinty scheme automatically
- **Responsive** - Use percentage widths with max-width caps for multi-monitor
- **Compact** - Smaller fonts (12px for overlays), tight spacing, no wasted space
- **No visual noise** - No borders, dotted lines, or alternating row colors in lists

## Zsh Setup
- **ZDOTDIR**: Set in `~/.zshenv` → `~/.config/zsh/` (all zsh dotfiles live there)
- `.zprofile` imports `environment.d` vars into login session (via `systemd-environment-d-generator`)
- `.zshrc` is the interactive shell config (plugins, aliases, completions)
- Plugin manager: Antidote (lightweight, pure zsh)
- GPG agent provides SSH agent (`enable-ssh-support` in `gpg-agent.conf`)
- `SSH_AUTH_SOCK` set via `environment.d/gpg.conf`, imported by `.zprofile`

## Display Manager
- **ly** (TUI display manager) — sources `~/.config/zsh/.zprofile` via its setup script
- `environment.d/*.conf` vars reach sway session through `.zprofile`

## Rofi Setup
- Base16 themed via tinty hook (generates colors.rasi from waybar colors.css)
- Font: Roboto 12px
- Window: 75% width, max 1200px, rounded corners (8px)
- Toggle behavior: same keybinding opens/closes (`pkill rofi || rofi ...`)
- Uniform list background (no alternating rows)
- Used for: app launcher, clipboard manager, file search, calculator, cheatsheet

## Waybar Setup
- Modern flat style with rounded modules
- Font: Roboto 15px, Nerd Font icons as fallback
- Custom modules for: network (with VPN), CPU, memory
- Tooltips show detailed info (top processes, battery health, etc.)
- Toggle scripts for floating dialogs (keepassxc, blueman, helvum)

## Patterns Established
- **Toggle scripts**: Check if visible, kill if yes, launch if no
- **Rofi toggle**: `pkill rofi || rofi ...` pattern in sway bindings
- **Floating windows**: Configured in `sway/config.d/floating.config`
- **Waybar custom modules**: Scripts in `~/.config/waybar/scripts/`
- **Icons**: Use nf-md-* icons (󰻠 󰍛 󰖩 etc.) - they render correctly
- **Tinty hooks**: New apps need a tinty item in config.toml.tmpl to auto-theme
- **Color generation**: Derive app colors from waybar colors.css (rofi, swaync, wob, obsidian, vivaldi)
- **Color coding**: Waybar module colors match related wob bar colors (e.g. base09 for audio)
- **Monospace font**: MesloLGS Nerd Font (for calendar, code, terminals)
- **Script standard**: `#!/usr/bin/env bash` + `set -euo pipefail` + `command -v` checks

## Key Bindings
- `Mod+Space` - App launcher (rofi, toggle)
- `Mod+Shift+f` - File search (rofi, toggle)
- `Mod+v` / `Mod+c` - Clipboard pick/clear (rofi)
- `Mod+Shift+s` - Toggle KeePassXC
- `Mod+Shift+b` - Toggle Blueman
- `Mod+Shift+w` - Network switcher (rofi, networkmanager_dmenu)
- `Mod+Shift+a` - Toggle Helvum audio patchbay
- `Mod+Shift+m` - Toggle Microscope
- `Mod+Shift+n` - Toggle notification center
- `Mod+Shift+u` - USB unmount (rofi, whole-disk eject)
- `Mod+?` - Cheatsheet browser (rofi)
- `Mod+=` / `Mod+Shift++` - Calculator (rofi, result to clipboard)
- `Mod+Shift+c` - Reload Sway (kills waybar first)
- Workspaces: `Mod+1-9` (switch), `Mod+Shift+1-9` (move)

## Tools in Use
- **VPN**: Netbird
- **Backups**: Restic via resticprofile
- **Audio**: PipeWire with Helvum patchbay
- **Dark/light**: Darkman switches tinty schemes (darktooth/gruvbox-light-medium)
- **Theming**: Tinty for base16 colors, hooks generate per-app color files
- **Sway reload**: Not triggered on theme switch (causes ~30s waybar restart); border colors update on manual reload
- **Editor**: Neovim with LazyVim (tinted-nvim for colors)
- **File search**: fd + find piped through rofi
- **Clipboard**: wl-clipboard + clipman + rofi
- **USB**: udiskie (no tray, auto-mount, mount notifications only) + rofi unmount
- **Tray icons**: Monochrome (blueman symbolic, keepassxc monochrome-dark)
- **Browsers**: Vivaldi (primary), Chromium; private mode entries in rofi
- **Screenshots**: `~/pictures/screenshots/` (sway + Vivaldi captures)

## Systemd User Units
Background daemons are managed as systemd user units rather than sway `exec` lines.
Custom unit files in `dot_config/systemd/user/`, enabled via `run_onchange_enable-systemd-units.sh`.
`swayidle` and app launches stay in sway config (need sway variables/workspace assignments).

## When Making Changes
1. Edit files in `~/.local/share/chezmoi/`
2. Apply individual files with `chezmoi apply <path>` (not full apply)
3. Test the change
4. **Update cheatsheet** if keybindings or user-facing behavior changed
5. **After testing**: review all uncommitted changes with `git status`/`git diff`, group into logical commits with descriptive messages, and push to GitHub

## Sway Script Pitfalls
- **No TTY**: Sway `exec` has no terminal — pagers, interactive prompts, and TTY detection fail silently
- **No focus guarantee**: Window focus may change before a watcher script runs — use metadata (e.g. MIME types) instead of focused window to identify event sources
- **Test from sway**: Always verify scripts with `swaymsg exec 'script.sh 2>/tmp/debug.log'`, not just from a terminal

## Shellcheck
Pre-commit hooks enforce shellcheck - fix warnings before committing.
