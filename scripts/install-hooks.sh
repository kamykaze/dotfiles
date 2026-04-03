#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_DIR="${DOTFILES_DIR}/.git/hooks"

echo "-> Installing git hooks..."

if [ ! -d "${HOOKS_DIR}" ]; then
    echo "  [warn] .git/hooks not found — not a git repo? Skipping."
    exit 0
fi

cp "${DOTFILES_DIR}/scripts/hooks/pre-commit" "${HOOKS_DIR}/pre-commit"
chmod +x "${HOOKS_DIR}/pre-commit"
echo "  [ok] pre-commit hook installed"
