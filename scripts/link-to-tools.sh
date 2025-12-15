#!/usr/bin/env bash
# Re-establish symlinks for Claude Code and Gemini to use shared superpowers
# Run this script after plugin updates or if symlinks are broken

set -euo pipefail

SUPERPOWERS_DIR="${HOME}/.superpowers"

echo "=== Linking ~/.superpowers to Claude Code and Gemini ==="

# Gemini
GEMINI_TARGET="${HOME}/.gemini/superpowers"
if [ -L "$GEMINI_TARGET" ]; then
    echo "✓ Gemini symlink already exists"
elif [ -d "$GEMINI_TARGET" ]; then
    echo "→ Backing up Gemini superpowers to ${GEMINI_TARGET}.backup"
    mv "$GEMINI_TARGET" "${GEMINI_TARGET}.backup"
    ln -s "$SUPERPOWERS_DIR" "$GEMINI_TARGET"
    echo "✓ Gemini symlink created"
else
    ln -s "$SUPERPOWERS_DIR" "$GEMINI_TARGET"
    echo "✓ Gemini symlink created"
fi

# Claude Code - find the superpowers plugin cache
CLAUDE_PLUGIN_BASE="${HOME}/.claude/plugins/cache/superpowers-marketplace/superpowers"
if [ -d "$CLAUDE_PLUGIN_BASE" ]; then
    # Find version directories (e.g., 3.6.2)
    for version_dir in "$CLAUDE_PLUGIN_BASE"/*/; do
        if [ -d "$version_dir" ]; then
            version_dir="${version_dir%/}"  # Remove trailing slash
            if [ -L "$version_dir" ]; then
                echo "✓ Claude symlink already exists: $version_dir"
            else
                echo "→ Backing up Claude plugin to ${version_dir}.backup"
                mv "$version_dir" "${version_dir}.backup"
                ln -s "$SUPERPOWERS_DIR" "$version_dir"
                echo "✓ Claude symlink created: $version_dir"
            fi
        fi
    done
else
    echo "⚠ Claude superpowers plugin not found at $CLAUDE_PLUGIN_BASE"
    echo "  Install the superpowers plugin first: /plugin superpowers"
fi

echo ""
echo "=== Done ==="
echo "Both tools now use: $SUPERPOWERS_DIR"
echo ""
echo "To update from upstream:"
echo "  cd ~/.superpowers"
echo "  git pull upstream main"
echo "  git push origin main"
