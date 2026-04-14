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

## Vivaldi loses connection to notification center

Chromium-based browsers connect to the D-Bus notification service once at startup.
If swaync restarts (crash, manual restart), Vivaldi won't reconnect — notifications silently stop working.

**Causes:**
- swaync crash-looping at boot (before `WAYLAND_DISPLAY` is set)
- Manual `systemctl --user restart swaync`

**Fix applied:**
- `ConditionEnvironment=WAYLAND_DISPLAY` in swaync.service prevents boot crash loops
- `StartLimitBurst=3` stops excessive restart attempts

**If it happens:**
- `swaync-client --reload-css && swaync-client -rs` (try first)
- Restart Vivaldi as last resort

**Rule:** Never restart swaync while Vivaldi is running. Use `swaync-client --reload-css` for theme changes (already done in tinty hook).

## Netbird VPN unstable / relay connections dropping

Symptom: Netbird relays constantly reconnect, peers can't stay connected, logs show `failed to read frame header: EOF`.

Root cause: Intel Raptor Lake WiFi (`iwlwifi`) misses beacons due to power management bug, causing WiFi to disconnect every ~35 seconds.

**Fix:** `/etc/modprobe.d/iwlwifi.conf` sets `options iwlmvm power_scheme=1` (CAM mode). See [ADR 003](adr/003-iwlwifi-disable-power-saving.md).

**Diagnosis:** Check `sudo dmesg | grep missed_beacons` — if you see counts climbing, the WiFi chip is sleeping through beacons.
