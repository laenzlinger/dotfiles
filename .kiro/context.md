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

## Rofi Setup
- Base16 themed via tinty hook (generates colors.rasi from waybar colors.css)
- Font: Roboto 12px
- Window: 75% width, max 1200px, rounded corners (8px)
- Toggle behavior: same keybinding opens/closes (`pkill rofi || rofi ...`)
- Uniform list background (no alternating rows)
- Used for: app launcher, clipboard manager, file search

## Waybar Setup
- Modern flat style with rounded modules
- Font: Roboto 15px, Nerd Font icons as fallback
- Custom modules for: network (with VPN), CPU, memory
- Tooltips show detailed info (top processes, battery health, etc.)
- Toggle scripts for floating dialogs (keepassxc, blueman, nm-connection-editor, helvum)

## Patterns Established
- **Toggle scripts**: Check if visible, kill if yes, launch if no
- **Rofi toggle**: `pkill rofi || rofi ...` pattern in sway bindings
- **Floating windows**: Configured in `sway/config.d/floating.config`
- **Waybar custom modules**: Scripts in `~/.config/waybar/scripts/`
- **Icons**: Use nf-md-* icons (󰻠 󰍛 󰖩 etc.) - they render correctly
- **Tinty hooks**: New apps need a tinty item in config.toml.tmpl to auto-theme
- **Color generation**: Derive app colors from waybar colors.css when no dedicated base16 repo exists

## Key Bindings
- `Mod+Space` - App launcher (rofi, toggle)
- `Mod+Shift+f` - File search (rofi, toggle)
- `Mod+v` / `Mod+c` - Clipboard pick/clear (rofi)
- `Mod+Shift+s` - Toggle KeePassXC
- `Mod+Shift+b` - Toggle Blueman
- `Mod+Shift+w` - Toggle Network Manager
- `Mod+Shift+m` - Toggle Microscope
- `Mod+Shift+n` - Toggle notification center
- `Mod+Shift+c` - Reload Sway (kills waybar first)

## Tools in Use
- **VPN**: Netbird
- **Backups**: Restic via resticprofile
- **Audio**: PipeWire with Helvum patchbay
- **Theming**: Tinty for base16 colors
- **Editor**: Neovim with LazyVim (tinted-nvim for colors)
- **File search**: fd + find piped through rofi
- **Clipboard**: wl-clipboard + clipman + rofi

## When Making Changes
1. Edit files in `~/.local/share/chezmoi/`
2. Apply individual files with `chezmoi apply <path>` (not full apply)
3. Test the change
4. **Update cheatsheet** if keybindings or user-facing behavior changed
5. Commit with descriptive message
6. Push to GitHub

## Shellcheck
Pre-commit hooks enforce shellcheck - fix warnings before committing.
