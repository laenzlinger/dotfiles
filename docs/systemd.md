# Systemd User Units

Background daemons are managed as systemd user units rather than sway `exec` lines.
This gives automatic restart on failure, clean per-service logs, and independence from sway reloads.

Custom unit files in `dot_config/systemd/user/`:
- `udiskie.service` — USB automounter
- `polkit-gnome.service` — PolicyKit authentication agent (Restart=always, critical service)
- `systembus-notify.service` — D-Bus notification bridge
- `shikane.service` — Display/output management
- `btrfs-desktop-notification.service` — Btrfs health notifications
- `blueman-applet.service` — Bluetooth system tray applet
- `swaync.service` — Sway notification center
- `clipboard-watcher.service` — Clipboard manager watcher (wl-paste)

All custom services include:
- `Type=simple` — explicit service type
- `Restart=on-failure` (or `always` for polkit-gnome)
- `RestartSec=3` — 3-second delay to prevent rapid restart loops

Units enabled automatically on fresh install via `run_onchange_enable-systemd-units.sh`.

System-provided services (enabled but not customized):
- `darkman.service` — Dark/light mode switcher (already has RestartSec=100ms)
- `syncthing.service` — File sync (already has RestartSec=1s)
- `wob.service` — Volume/brightness overlay (socket-activated, no restart needed)

Stays in sway config:
- `waybar` — Launched by Sway's bar config, needs to restart on display changes and reload on theme changes
- `swayidle` — Uses sway `$lock` variable
- App launches (`vivaldi`, `terminal`, `keepassxc`) — Need workspace assignments

## Monitoring

View service logs:
```bash
# Individual service
journalctl --user -u swaync -f

# Multiple services
journalctl --user -u polkit-gnome -u udiskie -u swaync --since today

# Check for errors
journalctl --user --since today | grep -iE "error|fail"

# Service status
systemctl --user status polkit-gnome
systemctl --user --failed
```
