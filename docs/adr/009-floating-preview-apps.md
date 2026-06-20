# ADR 009: Floating preview apps with consistent vim-style navigation

**Date:** 2026-06-20

**Status:** Accepted

## Context

Opening documents, images, 3D models, or videos from a file manager or terminal caused them to tile into the current workspace layout, disrupting the working context. These are typically quick previews, not long-lived windows.

Additionally, each viewer had different keybindings for common actions (quit, navigate, zoom), creating cognitive overhead when switching between tools.

## Decision

Configure all preview/viewer apps as floating windows with consistent vim-style keybindings:

**Floating windows** (centered, 80–95% screen size):
- `zathura` — PDF/ebook (95×95% for dual-page view)
- `swayimg` — images (80×90%)
- `mpv` — video/audio (80×90%)
- `f3d` — 3D models (80×90%)

**Consistent keybindings across viewers:**

| Action | Key |
|--------|-----|
| Quit | `q` |
| Next/Previous | `l` / `h` or `j` / `k` |
| First/Last | `g` / `G` |
| Zoom in/out | `+` / `-` |
| Zoom reset | `0` |

**Tool choices:**
- Replaced imv with `swayimg` (native Wayland, lighter)
- Replaced vlc with `mpv` (lighter, same codecs via FFmpeg)
- All media mime types routed via `xdg-open` to these tools

## Consequences

### Positive
- Previews don't disrupt tiling layout
- `q` dismisses any preview instantly
- Muscle memory transfers between all viewers and Firefox (vim-style browsing)
- Lighter resource footprint (removed vlc + 35 plugins)

### Negative
- Custom swayimg config needed (Lua) to override default keybindings
- `focus_on_window_activation focus` may steal focus in rare edge cases
