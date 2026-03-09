# Troubleshooting

## Empty line at terminal start

If you see an empty line before the first prompt when opening a new terminal, check:
- `add_newline = false` in `~/.config/starship/starship.toml`
- No empty lines at the start of `~/.zshrc`

## Waybar not updating after config change

Sway reload (`Mod+Shift+c`) kills waybar first, then reloads sway config which restarts waybar.

## Theme colors not applying to new app

Add the app to tinty config in `dot_config/tinted-theming/tinty/config.toml.tmpl` and create a hook script in `dot_config/tinted-theming/tinty/hooks/`.

## Toggle script not working

Check if the app is installed — toggle scripts use `command -v` to verify before launching.
