# ADR 005: New terminal windows inherit cwd via precmd file

**Date:** 2026-04-14

**Status:** Accepted

## Context

`Mod+Return` should open a new WezTerm window in the same working directory as the terminal you were just using. WezTerm's mux supports `wezterm cli spawn --new-window --cwd <path>`, but the challenge is knowing *which* directory to use.

### Approaches considered and rejected

1. **WezTerm lua keybinding (`Super+Return`)** — Sway grabs `Mod4+Return` before WezTerm sees it. WezTerm never receives the key.

2. **Embed pane ID in window title** — WezTerm's `format-window-title` can append `[pane:12]` to titles, letting the sway binding extract the pane ID and look up its cwd. Works technically, but pollutes the window title with noise.

3. **Match sway focused PID to wezterm pane** — All wezterm windows share a single PID in sway (the GUI process). There's no way to map a sway window to a specific mux pane from outside.

4. **`file://` URLs with `--cwd`** — `wezterm cli spawn --cwd` requires a plain filesystem path; `file://host/path` URLs are silently ignored.

## Decision

Use a two-part mechanism:

1. **Zsh precmd hook** writes `$PWD` to `$XDG_RUNTIME_DIR/wezterm-last-cwd` on every prompt.
2. **Sway binding** runs `wezterm-spawn.sh`, which reads that file and passes it to `wezterm cli spawn --new-window --cwd`.

Falls back to a plain `wezterm` launch if the file is missing or the mux isn't running.

### Files involved

- `dot_config/zsh/dot_zshrc.tmpl` — `_wezterm_track_cwd` precmd function
- `dot_config/sway/bin/executable_wezterm-spawn.sh` — spawn script
- `dot_config/sway/config` — `Mod+Return` binding

## Consequences

### Positive
- Simple, no window-matching complexity
- No visual changes (clean window titles)
- Graceful fallback when no terminal has been used yet

### Negative
- Tracks the *last interacted* terminal, not the *currently focused* one — if you mouse-focus a terminal without running a command, `Mod+Return` uses the previous terminal's cwd
- Single-file approach means parallel workflows can collide

### Future improvement
If the single-file behavior proves problematic, switch to per-pane files (`wezterm-cwd-$WEZTERM_PANE`) and pick the most recently modified one matching the focused window.
