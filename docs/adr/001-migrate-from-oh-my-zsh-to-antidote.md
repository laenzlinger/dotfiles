# ADR 001: Migrate from oh-my-zsh to antidote

**Date:** 2026-03-09

**Status:** Accepted

## Context

We use zsh with oh-my-zsh across multiple systems (Arch Linux, Ubuntu, Raspberry OS, macOS). Current startup time is ~210ms, and oh-my-zsh feels bloated with 15k+ lines of code for functionality we barely use.

### Requirements
- Multi-OS support (Arch, Ubuntu, Raspberry OS, macOS)
- Consistent installation method across all systems
- Security-conscious (minimal, auditable codebase)
- Fast startup time (<100ms target)
- XDG Base Directory compliance
- Maintain existing functionality (aliases, completions, transient prompt)

### Current Plugin Usage
We use 18 oh-my-zsh plugins, but analysis shows:
- 5 plugins = just aliases (~30 lines we could extract)
- 8 plugins = just completions (tools provide these natively)
- 3 plugins = functionality (fzf, z, transient-prompt)
- 2 plugins = OS-specific (archlinux, systemd)

Most plugins don't require a framework.

## Decision

**Migrate to antidote** with XDG-compliant directory structure.

### Why antidote?

**Evaluated alternatives:**
1. **Bare zsh** - Maximum control, but requires many OS-specific conditionals for plugin paths
2. **Prezto** - Not packaged on any system, 14k stars but development slowed
3. **Zinit** - More complex, not packaged anywhere, 4.5k stars
4. **Antidote** - Simple, pure zsh, 1.5k stars but actively maintained

**Antidote wins because:**
- Pure zsh script (~1000 lines, auditable)
- Same installation method as oh-my-zsh (git clone via chezmoi external)
- Works identically on all our systems
- Simple plugin management (text file listing)
- Fast startup (~80-100ms expected)
- Small, focused codebase (security)
- Can load oh-my-zsh plugins if needed
- Active development, low issue count (13 open issues)

### Installation Method

Use chezmoi external (same as current oh-my-zsh approach):
```toml
[".antidote"]
    type = "git-repo"
    url = "https://github.com/mattmc3/antidote.git"
    refreshPeriod = "168h"
```

This provides:
- Consistent path across all systems (`~/.antidote/`)
- Automatic updates via chezmoi
- No package manager dependencies
- Works on all our systems

### Directory Structure

Adopt XDG Base Directory specification:
```
~/.antidote/                    # antidote itself (chezmoi external)
~/.config/zsh/
  ├── .zshrc                    # main config
  └── .zsh_plugins.txt          # plugin list
~/.local/share/antidote/        # cached plugins (ANTIDOTE_HOME)
```

### Plugin Migration

**Replace:**
- `z` plugin → `zoxide` (already installed, faster)
- oh-my-zsh plugins → direct GitHub repos or native completions
- `transient-prompt` → `olets/zsh-transient-prompt` (upstream source)

**Keep:**
- Essential aliases (extract to .zshrc)
- Native tool completions (kubectl, terraform, aws, gh, etc.)
- Syntax highlighting, autosuggestions (via antidote)

## Consequences

### Positive
- Faster startup time (~80-100ms vs ~210ms)
- Smaller, auditable codebase (~1k lines vs ~15k lines)
- Same portability as oh-my-zsh (works on all systems)
- XDG-compliant (cleaner home directory)
- Less maintenance (fewer moving parts)
- Better security (less code to audit)

### Negative
- Migration effort (1-2 hours initial setup)
- Smaller community (1.5k stars vs 185k)
- Need to test on all systems (Arch, Ubuntu, Raspberry OS, macOS)
- Less "batteries included" (more explicit about what we load)

### Neutral
- Still using a framework (not bare zsh)
- Still using git clone for installation
- Plugin ecosystem same (can still use oh-my-zsh plugins if needed)

## Implementation Plan

1. Add antidote to `.chezmoiexternal.toml`
2. Create `dot_config/zsh/dot_zsh_plugins.txt.tmpl` with plugin list
3. Update `dot_zshrc.tmpl` to:
   - Set `ZDOTDIR` for XDG compliance
   - Load antidote
   - Replace oh-my-zsh-specific code
4. Extract essential aliases to `.zshrc`
5. Set up native completions for tools
6. Test on Arch Linux first
7. Roll out to other systems
8. Remove oh-my-zsh from `.chezmoiexternal.toml` after verification

## References

- [antidote GitHub](https://github.com/mattmc3/antidote)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [zsh-transient-prompt](https://github.com/olets/zsh-transient-prompt)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
