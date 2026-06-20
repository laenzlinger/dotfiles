# ADR 008: Security hardening for roaming laptop

**Date:** 2026-06-20

**Status:** Accepted

## Context

The laptop connects to untrusted networks (public wifi, tethering, hotel networks). By default, Arch Linux has no firewall, broadcasts the real hardware MAC address, and uses stable IPv6 addresses derived from the hardware identifier — all of which aid tracking and expose the system to unsolicited inbound connections.

Additionally, default sudo timeout and kernel access controls are overly permissive for a mobile device.

## Decision

Apply the following hardening measures on each machine.

### 1. Firewall (firewalld)

```bash
sudo pacman -S firewalld
sudo systemctl enable --now firewalld
```

Default zone `public` blocks all inbound except DHCP, mDNS, and DHCPv6-client. No custom rules needed for a laptop.

### 2. MAC address randomization

`/etc/NetworkManager/conf.d/wifi-privacy.conf`:

```ini
[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=stable
ethernet.cloned-mac-address=stable
```

- `scan-rand-mac-address=yes` — random MAC during wifi scans (prevents passive tracking)
- `cloned-mac-address=stable` — deterministic MAC per-network (different SSID = different MAC, but same SSID = consistent MAC so DHCP leases and captive portals work)

### 3. IPv6 privacy extensions

`/etc/sysctl.d/40-ipv6-privacy.conf`:

```ini
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
```

Uses temporary IPv6 addresses (RFC 4941) instead of stable addresses derived from the hardware MAC.

### 4. Sudo timeout

`/etc/sudoers.d/timeout`:

```
Defaults timestamp_timeout=5
```

Reduces sudo credential cache from 15 minutes to 5 minutes.

### 5. Kernel lockdown (integrity mode)

Add `lockdown=integrity` to kernel command line in `/boot/loader/entries/arch.conf`.

Prevents:
- Loading unsigned kernel modules
- Access to `/dev/mem`, `/dev/kmem`, `/dev/port`
- kexec of unsigned kernels
- Writing to MSRs

Safe on ThinkPads with mainline drivers only. If something breaks, remove the parameter at the boot menu (press `e`).

## Consequences

### Positive

- Inbound attack surface eliminated on untrusted networks
- MAC-based tracking across locations prevented
- IPv6 address no longer reveals hardware identity
- Reduced window for privilege escalation via sudo
- Kernel memory protected from userspace tampering
- No user-facing impact — all transparent

### Negative

- Firewalld adds a daemon (minimal resource use)
- `stable` MAC may confuse networks that whitelist by MAC (rare; use real MAC override per-connection if needed)
- Some captive portals may require re-authentication after MAC changes (mitigated by `stable` mode)
- Kernel lockdown may break out-of-tree/DKMS modules (not used on this hardware)
