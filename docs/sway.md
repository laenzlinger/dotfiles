# Sway

## Patterns

- **Toggle scripts**: Check if visible, kill if yes, launch if no
- **Rofi toggle**: `pkill rofi || rofi ...` pattern in bindings
- **Floating windows**: Configured in `sway/config.d/floating.config`

## Script Pitfalls

- **No TTY**: Sway `exec` has no terminal — pagers, interactive prompts, and TTY detection fail silently
- **No focus guarantee**: Window focus may change before a watcher script runs — use metadata (e.g. MIME types) instead of focused window to identify event sources
- **Test from sway**: Always verify scripts with `swaymsg exec 'script.sh 2>/tmp/debug.log'`, not just from a terminal
