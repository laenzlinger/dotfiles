# Zsh Configuration

## XDG compliance

`~/.zshenv` sets `ZDOTDIR=~/.config/zsh`, so all zsh dotfiles live there:

- `.zshrc` — interactive shell config (plugins, aliases, completions)
- `.zprofile` — login session setup (imports `environment.d` vars on Linux)
- `.zsh_plugins.txt` — antidote plugin list

## Plugin manager

[Antidote](https://github.com/mattmc3/antidote) — a lightweight pure-zsh plugin manager.
See [ADR 001](adr/001-migrate-from-oh-my-zsh-to-antidote.md) for the migration rationale.

Plugins are listed in `dot_config/zsh/dot_zsh_plugins.txt.tmpl`.

## Startup performance

Shell startup is ~260ms. Key optimizations:

- `compinit -C` — skips `compaudit` permission check (~12ms saved)
- No direnv — mise handles per-project env vars via `.mise.local.toml`
- `bashcompinit` loaded once for both terraform and aws completions
- PATH/LANG/EDITOR moved to `environment.d` (not evaluated at shell start)

### Profiling

To profile startup, temporarily add to the top/bottom of `.zshrc`:

```zsh
# top
zmodload zsh/zprof

# bottom
zprof
```

For wall-clock time: `time zsh -i -c exit`

## Per-project environment

Use `.mise.local.toml` (gitignored globally) instead of `.envrc`:

```toml
[env]
SECRET_KEY = "dev-only-value"
DATABASE_URL = "postgres://localhost/mydb"
```

## Chezmoi template

`.zshrc` is a chezmoi template (`dot_zshrc.tmpl`). Platform-specific logic:

- `osRelease.id == "arch"` — Arch-specific paths (fzf, pacman, pkgfile)
- `os == "linux"` — systemd aliases, `xdg-open` alias
- `os == "darwin"` — Homebrew paths, environment.d sourcing, Amazon Q
