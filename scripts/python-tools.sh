#!/usr/bin/env bash
set -e

# ============================================================
# Python virtualenv for this repo's helper scripts.
#
# Homebrew's python is marked EXTERNALLY-MANAGED (PEP 668), so `pip3 install`
# into it fails outright, and --break-system-packages re-breaks on every python
# upgrade. A dedicated venv keeps the deps declared and survives rebuilds.
#
# The venv is gitignored — requirements.txt is the declaration, not the venv.
# ============================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="${DOTFILES_DIR}/.venv-tools"
REQS="${DOTFILES_DIR}/utilities/scripts/requirements.txt"

echo "-> Setting up Python venv for helper scripts..."

if [ ! -f "${REQS}" ]; then
    echo "  [skip] no requirements.txt at ${REQS}"
    exit 0
fi

if [ ! -x "${VENV}/bin/python" ]; then
    python3 -m venv "${VENV}"
    echo "  [ok] created ${VENV}"
else
    echo "  [skip] venv already exists"
fi

# --quiet so a satisfied venv prints nothing; pip is idempotent here.
if "${VENV}/bin/pip" install --quiet --upgrade -r "${REQS}"; then
    echo "  [ok] dependencies installed from requirements.txt"
else
    echo "  [warn] pip install failed — 'kanata-viz' will not run until it succeeds"
fi
