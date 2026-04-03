#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "-> Setting up Homebrew..."

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
    echo "  Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for Apple Silicon
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "  [skip] Homebrew already installed"
fi

# Install all packages from Brewfile
if [ -f "${DOTFILES_DIR}/Brewfile" ]; then
    echo "  Installing packages from Brewfile..."
    brew bundle --file="${DOTFILES_DIR}/Brewfile" --no-lock
    echo "  Done."
else
    echo "  [warn] No Brewfile found at ${DOTFILES_DIR}/Brewfile"
fi
