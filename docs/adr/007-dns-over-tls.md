# ADR 007: Enable DNS-over-TLS via systemd-resolved

**Date:** 2026-06-20

**Status:** Accepted

## Context

With systemd-resolved in place (ADR 006), DNS queries from the system go unencrypted to the Swisscom router (`192.168.1.1`), which forwards them to Swisscom's DNS servers. This exposes all DNS lookups to the ISP in plaintext.

The Swisscom Internet-Box does not support DNS-over-HTTPS or DNS-over-TLS, so encryption must be configured at the client level.

## Decision

Enable DNS-over-TLS in systemd-resolved using Quad9 as the upstream resolver, with `opportunistic` mode to preserve local DNS routing.

### Configuration

`/etc/systemd/resolved.conf.d/dns-over-tls.conf`:

```ini
[Resolve]
DNS=9.9.9.9#dns.quad9.net 2620:fe::9#dns.quad9.net 149.112.112.112#dns.quad9.net
FallbackDNS=1.1.1.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com
DNSOverTLS=opportunistic
Domains=~.
```

### How it works

- `Domains=~.` makes the global DNS (Quad9) the default route for all queries
- Per-link DNS (from NetworkManager/Netbird) still takes priority for matching domains:
  - `*.home` → Swisscom router via wifi link (plain DNS)
  - `*.netbird.cloud` → Netbird DNS via wireguard link (plain DNS)
  - Everything else → Quad9 over TLS
- `DNSOverTLS=opportunistic` uses TLS when the server supports it, falls back to plain DNS for link-local servers that don't

### Why Quad9

- Swiss-based (Zurich), GDPR-compliant, no logging
- Supports DNS-over-TLS
- Blocks known malicious domains

## Consequences

### Positive

- DNS queries encrypted in transit — ISP cannot observe lookups
- Malicious domain blocking via Quad9
- No breakage of local name resolution (`*.home`, `*.netbird.cloud`)
- No additional software needed (built into systemd-resolved)

### Negative

- Slightly higher latency for first queries (TLS handshake)
- Quad9 sees our query patterns (trade ISP visibility for resolver visibility)
- `opportunistic` mode does not fail closed — falls back to plain DNS if TLS fails
