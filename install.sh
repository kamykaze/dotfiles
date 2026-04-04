#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${DOTFILES_DIR}/scripts"

echo "============================================"
echo "  Dotfiles Bootstrap"
echo "============================================"
echo ""

# ============================================================
# Xcode Command Line Tools (required for git, make, brew, etc.)
# ============================================================
if ! xcode-select -p &>/dev/null; then
    echo "-> Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "   Waiting for installation to complete..."
    until xcode-select -p &>/dev/null; do sleep 5; done
    echo "   Done."
    echo ""
fi

# ============================================================
# Homebrew + packages
# ============================================================
bash "${SCRIPTS_DIR}/homebrew.sh"
echo ""

# ============================================================
# Symlinks (_* -> ~/.)
# ============================================================
bash "${SCRIPTS_DIR}/symlinks.sh"
echo ""

# ============================================================
# Git submodules (Vim plugins, etc.)
# Only requires HTTPS — no SSH keys needed.
# Failures are non-fatal; submodules can be updated later with:
#   git submodule update --init --recursive
# ============================================================
echo "-> Syncing git submodules..."
cd "${DOTFILES_DIR}"
git submodule sync --quiet || true
git submodule update --init --recursive --quiet 2>/dev/null || \
    echo "  [warn] Some submodules failed to fetch (run 'git submodule update --init' manually)"
echo "   Done."
echo ""

# ============================================================
# VS Code configuration
# ============================================================
if [ -f "${DOTFILES_DIR}/utilities/scripts/setup-vscode.sh" ]; then
    echo "-> Setting up VS Code configuration..."
    bash "${DOTFILES_DIR}/utilities/scripts/setup-vscode.sh"
    echo ""
fi

# ============================================================
# Git hooks (pre-commit sensitive data scanner)
# ============================================================
bash "${SCRIPTS_DIR}/install-hooks.sh"
echo ""

# ============================================================
# Launch Agents (Kanata, daily sync, etc.)
# ============================================================
bash "${SCRIPTS_DIR}/launchagents.sh"
echo ""

# ============================================================
# macOS system preferences (optional — comment out to skip)
# ============================================================
# Uncomment the line below to apply macOS defaults on first run:
# bash "${SCRIPTS_DIR}/macos.sh"
# echo ""

# ============================================================
# Switch remote origin from HTTPS to SSH (if needed)
# ============================================================
cd "${DOTFILES_DIR}"
CURRENT_REMOTE="$(git remote get-url origin 2>/dev/null || true)"
if [[ "${CURRENT_REMOTE}" == https://github.com/* ]]; then
    SSH_REMOTE="${CURRENT_REMOTE/https:\/\/github.com\//git@github.com:}"
    echo "-> Switching remote origin from HTTPS to SSH..."
    echo "   ${CURRENT_REMOTE} -> ${SSH_REMOTE}"
    git remote set-url origin "${SSH_REMOTE}"
    echo "   Done."
else
    echo "-> Remote origin is already using SSH (or non-GitHub). No change needed."
fi
echo ""

echo "============================================"
echo "  Bootstrap complete!"
echo ""
echo "  Next steps:"
echo "  - Review SETUP_NOTES.md for manual steps"
echo "  - Run scripts/macos.sh to apply system preferences"
echo "  - See apps.md for apps that need manual install"
echo "============================================"
