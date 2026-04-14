# ADR 003: Disable Intel WiFi power saving (iwlmvm power_scheme=1)

**Date:** 2026-03-28

**Status:** Accepted

## Context

Netbird VPN was extremely unstable — relay WebSocket connections to Frankfurt servers (`streamline-de-fra1-*.relay.netbird.io`) were dropping with EOF errors every few seconds, causing a constant reconnect storm. Only 1 of 4 peers could stay connected.

Investigation revealed the root cause was not Netbird but the WiFi driver. The Intel Raptor Lake WiFi chip (X1 Carbon Gen 12, `iwlwifi` driver) was missing beacons continuously, causing ~310 WiFi disconnections in 3 hours (~1 every 35 seconds). Each WiFi drop killed all Netbird relay connections.

Kernel logs showed:
```
iwlwifi 0000:00:14.3: missed_beacons:30, missed_beacons_since_rx:3
iwlwifi 0000:00:14.3: missed beacons exceeds threshold, but receiving data. Stay connected, Expect bugs.
```

Signal strength was 89% — not a range issue. This is a known `iwlwifi` driver bug on Raptor Lake where the chip's power management causes it to sleep through AP beacons.

## Decision

Set `iwlmvm power_scheme=1` (CAM — Continuously Aware Mode) via `/etc/modprobe.d/iwlwifi.conf`.

This keeps the WiFi radio active at all times instead of sleeping between beacons.

### Changes

1. Created `/etc/modprobe.d/iwlwifi.conf` (outside chezmoi — system-level config):
   ```
   options iwlmvm power_scheme=1
   ```

### Verification

After applying the change:
- Zero WiFi disconnects (was ~1 every 35 seconds)
- Zero missed beacons in dmesg (was hitting 20-30+ continuously)
- Netbird relay connections stable, all 4 relays available
- Zero relay disconnects (was ~375 in 3 hours)

## Consequences

### Positive
- WiFi connection fully stable
- Netbird VPN reliable
- All relay and peer connections maintained

### Negative
- ~0.5–1W extra power draw (WiFi radio stays active)
- Estimated 30–60 minutes less battery life per charge

### Revisit when
- Intel fixes the `iwlwifi` driver for Raptor Lake beacon handling
- Kernel upgrade resolves the issue (check after major `linux` package updates)
- Battery life becomes a concern — `power_scheme=3` (low power) could be tested as a middle ground, but given the chip misbehaves on balanced (2), CAM (1) is the safe choice

## References

- [iwlwifi known issues — kernel.org](https://wireless.wiki.kernel.org/en/users/drivers/iwlwifi)
- [Arch Wiki — Intel WiFi](https://wiki.archlinux.org/title/Network_configuration/Wireless#iwlwifi)
- Kernel: 6.19.8-arch1-1, netbird: 0.67.1
