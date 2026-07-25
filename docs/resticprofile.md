# Resticprofile

Backups via restic, managed with resticprofile.

## Pitfalls

- **`check-battery: true` aborts mid-run**: It doesn't just check at start — it monitors during backup and sends SIGINT to restic if it detects battery. On USB-C docks, power state can briefly flicker during PD negotiation, causing false positives. Disable for profiles that only run when docked/on AC.
- **Status file doesn't distinguish success/failure**: The "too recent" skip check uses `backup.time` regardless of `backup.success`. A failed backup blocks retries until the threshold (13h) passes.
