# TODO

- [ ] Centralize backup disk UUIDs — duplicated in udev rules and restic-snapshots.sh
- [ ] NAS backup target via rest-server
  - Run `rest-server --append-only` on NAS (container or systemd service)
  - Add `nas` profile in resticprofile: `rest:http://<nas>:8000/gibson-home`
  - Reachability check in `run-before` (curl/ping, skip if offline)
  - Add to `rotating-backup` group (skips gracefully like USB disks when not home)
- [ ] Better dark/light theming for Electron apps
- [x] Theme Vivaldi with tinted-theming base16 colors
- [ ] Generate base16 theme from wallpaper image
- [ ] Evaluate if lazy-lock.json should be managed by chezmoi or gitignored

### Nice to have

- [ ] Theme GTK apps with tinted-theming base16 colors
- [ ] Theme Qt apps with tinted-theming base16 colors
