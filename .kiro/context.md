# Laenzi's Arch Linux Development Context

## System Overview
- **OS**: Arch Linux on ThinkPad X1 Carbon Gen 12
- **Window Manager**: Sway (Wayland)
- **Dotfiles**: Managed with chezmoi at `~/.local/share/chezmoi`
- **Theme**: Base16 colors via tinty (auto-switches across apps)
- **Shell**: Zsh with Starship prompt

## Design Preferences
- **Simple and modern** - Clean, minimal UI
- **Consistent** - Same patterns across tools
- **Functional** - Info visible without hovering when possible
- **Theme-aware** - Colors should adapt to tinty scheme

## Waybar Setup
- Modern flat style with rounded modules
- Font: Roboto 15px, Nerd Font icons as fallback
- Custom modules for: network (with VPN), CPU, memory
- Tooltips show detailed info (top processes, battery health, etc.)
- Toggle scripts for floating dialogs (keepassxc, blueman, nm-connection-editor, helvum)

## Patterns Established
- **Toggle scripts**: Check if visible, kill if yes, launch if no
- **Floating windows**: Configured in `sway/config.d/floating.config`
- **Waybar custom modules**: Scripts in `~/.config/waybar/scripts/`
- **Icons**: Use nf-md-* icons (󰻠 󰍛 󰖩 etc.) - they render correctly

## Key Bindings
- `Mod+Shift+s` - Toggle KeePassXC
- `Mod+Shift+b` - Toggle Blueman
- `Mod+Shift+w` - Toggle Network Manager
- `Mod+Shift+c` - Reload Sway (kills waybar first)

## Tools in Use
- **VPN**: Netbird
- **Backups**: Restic via resticprofile
- **Audio**: PipeWire with Helvum patchbay
- **Theming**: Tinty for base16 colors
- **Editor**: Neovim with LazyVim (tinted-nvim for colors)

## When Making Changes
1. Edit files in `~/.local/share/chezmoi/`
2. Apply with `chezmoi apply <path>`
3. Test the change
4. Commit with descriptive message
5. Push to GitHub

## Shellcheck
Pre-commit hooks enforce shellcheck - fix warnings before committing.
