# Systemd User Units

Background daemons are managed as systemd user units rather than sway `exec` lines.
This gives automatic restart on failure, clean per-service logs, and independence from sway reloads.

Custom unit files in `dot_config/systemd/user/`:
- `udiskie.service` — USB automounter
- `polkit-gnome.service` — PolicyKit authentication agent
- `systembus-notify.service` — D-Bus notification bridge
- `shikane.service` — Display/output management
- `btrfs-desktop-notification.service` — Btrfs health notifications

Units enabled automatically on fresh install via `run_onchange_enable-systemd-units.sh`.

Stays in sway config:
- `swayidle` — uses sway `$lock` variable
- App launches (`vivaldi`, `terminal`, `keepassxc`) — need workspace assignments
