# ADR 002: Use UWSM for Sway session management

**Date:** 2026-03-11

**Status:** Accepted

## Context

User systemd services (udiskie, shikane, polkit-gnome, systembus-notify, btrfs-desktop-notification) are configured with `WantedBy=graphical-session.target` but never start because nothing activates that target. Sway's built-in systemd integration (`/etc/sway/config.d/50-systemd-user.conf`) only imports environment variables — it does not start `graphical-session.target`.

Additionally, `graphical-session.target` has `RefuseManualStart=yes`, so it cannot be started directly. Systemd expects a compositor-specific target to bind to it.

On logout, services were also not properly stopped, causing stale processes and failed restarts on re-login.

### Requirements
- Start user services when Sway session begins
- Stop user services cleanly when Sway session ends
- Proper environment variable propagation to systemd and D-Bus
- Work with ly display manager

### Evaluated alternatives

1. **Manual `systemctl start graphical-session.target`** — Blocked by `RefuseManualStart=yes`
2. **sway-systemd** (alebastr) — Sway-specific, provides `sway-session.target` and a session script with cleanup. Requires AUR or manual install
3. **sway-services** (AUR) — Runs sway itself as a systemd service. Discouraged by sway maintainers
4. **Custom sway-session.target + exec lines** — Sway wiki suggests `exec swaymsg -t subscribe '["shutdown"]' && systemctl --user stop sway-session.target` for cleanup. Fragile, manual wiring
5. **UWSM** — Universal Wayland Session Manager. In official Arch repos. Handles startup, environment, shutdown for any Wayland compositor

## Decision

**Use UWSM** to manage the Sway session.

### Why UWSM?

- In official Arch repos (`extra/uwsm`), not AUR
- Compositor-agnostic — works if we ever switch from Sway
- Handles full lifecycle: start `graphical-session.target`, propagate env, clean shutdown
- Works with any display manager including ly
- Recommended by Arch Wiki and Hyprland Wiki
- Active development
- Works with dbus-broker (already installed)

### Changes

1. Created `/usr/share/wayland-sessions/sway-uwsm.desktop` — ly shows "Sway (UWSM)" session
2. Replaced `dbus-update-activation-environment` with `exec uwsm finalize` in sway config
3. Changed `swaymsg exit` to `uwsm stop` in power menu for clean shutdown

### Session flow

1. ly launches `uwsm start -N "Sway" -D sway -- sway`
2. uwsm creates systemd units, starts sway, activates `graphical-session.target`
3. Sway runs `exec uwsm finalize` to propagate `WAYLAND_DISPLAY` etc.
4. User services (udiskie, shikane, etc.) start via `WantedBy=graphical-session.target`
5. On logout, `uwsm stop` cleanly stops all services and the session target

## Consequences

### Positive
- User services start and stop reliably with the graphical session
- Clean environment propagation (no manual `dbus-update-activation-environment`)
- Clean shutdown (no stale processes after logout)
- Future-proof (works with any Wayland compositor)

### Negative
- Additional dependency (`uwsm`)
- Must use `uwsm stop` instead of `swaymsg exit` for clean shutdown
- Session entry (`sway-uwsm.desktop`) is outside chezmoi management

## References

- [UWSM — Arch Wiki](https://wiki.archlinux.org/title/Universal_Wayland_Session_Manager)
- [UWSM GitHub](https://github.com/Vladimir-csp/uwsm)
- [sway-systemd GitHub](https://github.com/alebastr/sway-systemd)
- [Sway systemd integration wiki](https://github.com/swaywm/sway/wiki/systemd-integration)
