# ADR 004: Keep sway keybinding commands simple, put logic in scripts

**Date:** 2026-04-14

**Status:** Accepted

## Context

Sway's `exec` directive runs commands through `sh -c`, but sway's own config parser processes the line first. Complex shell constructs — braces `{ }`, subshells, compound conditionals — can cause parse failures with cryptic errors like `Unknown/invalid command '}'`.

This was discovered when adding auto-mute-at-zero logic to the volume-down keybinding. Inline shell like:

```
bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && { [ "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2 * 100}')" = "0" ] && wpctl set-mute @DEFAULT_AUDIO_SINK@ 1 || true; } && $volume
```

Failed silently — sway's parser rejected the braces before the command ever reached `sh -c`.

## Decision

Keep sway `exec` bindings as simple one-liner invocations. Any logic beyond a single command with `&&` chaining belongs in a script.

**Pattern:**
```
# Good — logic in script
bindsym XF86AudioLowerVolume exec ~/.config/sway/bin/volume.sh down > $WOBSOCK

# Bad — complex shell inline
bindsym XF86AudioLowerVolume exec cmd1 && { [ ... ] && cmd2 || true; } && cmd3
```

## Consequences

### Positive
- Keybindings are readable and predictable
- Scripts can use full bash features (`set -euo pipefail`, functions, etc.)
- Easier to test: `swaymsg exec 'script.sh'` or run directly in terminal
- Shellcheck catches issues in scripts (pre-commit hook)

### Negative
- More script files in `~/.config/sway/bin/`
- Slightly more indirection when tracing what a keybinding does

## References

- [Sway exec documentation](https://man.archlinux.org/man/sway.5#COMMANDS)
