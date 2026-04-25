# PAM Configuration

PAM files live in `/etc/pam.d/` (system-level, not managed by chezmoi).

## Fingerprint Authentication

fprintd is enabled for sudo and polkit only. Swaylock, ly, and TTY login use password only (fingerprint UX is unclear without visual feedback).

### /etc/pam.d/sudo

```
#%PAM-1.0
auth		sufficient	pam_fprintd.so max-tries=3 timeout=20
auth		include		system-auth
account		include		system-auth
session		include		system-auth
```

### /etc/pam.d/polkit-1

```
#%PAM-1.0
auth sufficient pam_fprintd.so max-tries=3 timeout=20

auth       include      system-auth
account    include      system-auth
password   include      system-auth
session    include      system-auth
```

### /etc/pam.d/swaylock

```
#%PAM-1.0
auth sufficient pam_unix.so try_first_pass nullok
auth required pam_deny.so
```

## Notes

- `max-tries=3 timeout=20`: 3 fingerprint attempts within 20 seconds, then falls back to password
- In terminal (sudo): Ctrl+C skips fingerprint and goes straight to password
- Swaylock/ly have no fingerprint because PAM is serial — no way to show which auth mode is active
- ly config: `allow_empty_password = false` in `/etc/ly/config.ini`
