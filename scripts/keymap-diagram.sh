#!/usr/bin/env bash
# Regenerate assets/keyboard-layers.svg from _configs/kanata.kbd.
# Run this after changing the kanata layers or the BetterTouchTool preset.
set -e

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v uv >/dev/null 2>&1; then
  echo "uv not found — install it with: brew install uv"
  exit 1
fi

echo "-> drawing kanata layers..."
# keymap-drawer's kanata parser is marked experimental upstream, so pin it:
# an upgrade should be a deliberate change with a look at the diff, not a
# surprise the next time this runs.
uv run --quiet \
  --with 'keymap-drawer==0.23.0' \
  --with pyyaml \
  python "$REPO/scripts/keymap-diagram.py"

echo "✓ done"
