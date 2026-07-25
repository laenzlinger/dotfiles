#!/usr/bin/env bash
set -euo pipefail

# hash: 2026-07-11-v5
# Deploy AI assistant config: symlinks from tool-specific locations to shared config

AI_DIR="$HOME/.config/ai"
RULES_DIR="$AI_DIR/rules"
AGENTS_SRC="$AI_DIR/agents"

TOOL_STEERING="$HOME/.kiro/steering"
TOOL_AGENTS="$HOME/.kiro/agents"

mkdir -p "$TOOL_STEERING" "$TOOL_AGENTS"

# Symlink shared rules into tool steering directory
for rule in "$RULES_DIR"/*.md; do
    [ -f "$rule" ] || continue
    name=$(basename "$rule")
    [ "$name" = "README.md" ] && continue
    ln -sf "$rule" "$TOOL_STEERING/$name"
done

# Symlink agent configs into tool agents directory
for agent in "$AGENTS_SRC"/*.json; do
    [ -f "$agent" ] || continue
    ln -sf "$agent" "$TOOL_AGENTS/$(basename "$agent")"
done
