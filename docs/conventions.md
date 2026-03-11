# Conventions

Guiding principles for this dotfiles repository.

## Package management

- Prefer official Arch repos (`core`, `extra`) over AUR whenever possible
- AUR packages are acceptable when no official alternative exists
- Document AUR dependencies explicitly when used

## Configuration

- Follow XDG Base Directory specification
- Manage dotfiles with chezmoi
- Keep configurations minimal and auditable

## Systemd

- Use systemd user services for session daemons
- Depend on `graphical-session.target` for desktop services
- Use UWSM for Wayland session lifecycle management

## Documentation

- Record significant decisions as ADRs in `docs/adr/`
- Keep docs close to what they describe
