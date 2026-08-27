#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${DOTFILES_DIR}/scripts"

# ============================================================
# Options
#   -y | --yes   skip the preflight prompt (also: DOTFILES_ASSUME_YES=1)
# ============================================================
ASSUME_YES="${DOTFILES_ASSUME_YES:-0}"
for arg in "$@"; do
    case "${arg}" in
        -y|--yes) ASSUME_YES=1 ;;
        -h|--help)
            echo "Usage: ./install.sh [-y|--yes]"
            echo "  -y, --yes   Skip the preflight prompt (for re-runs and automation)"
            exit 0
            ;;
        *) echo "Unknown option: ${arg}" >&2; exit 64 ;;
    esac
done

echo "============================================"
echo "  Dotfiles Bootstrap"
echo "============================================"
echo ""

# ============================================================
# Preflight — SETUP_NOTES.md covers prerequisites and the manual steps this
# script cannot do. Easy to run install.sh first and read the notes after,
# so make that an explicit choice rather than the default.
# ============================================================
if [ "${ASSUME_YES}" -ne 1 ]; then
    cat <<'PREFLIGHT'
  READ SETUP_NOTES.md FIRST
  -------------------------
  It covers the prerequisites and the manual steps this script can't do.

      less SETUP_NOTES.md

  Before you continue, know that:

    * Homebrew installs everything in the Brewfile, casks included. This takes
      a while and will ask for your password — some casks need sudo.
    * The Kanata launch daemon goes into /Library/LaunchDaemons (sudo).
    * At the very end this repo's git remote is switched from HTTPS to SSH.
      Restore your SSH keys from LastPass first (SETUP_NOTES.md section 1),
      or pushes will fail until you do.
    * macOS system preferences are NOT applied here. Run
      'bash scripts/macos.sh' afterwards — sync.sh keeps macOS prefs disabled
      until you have.
    * Existing dotfiles that aren't symlinks are skipped, never overwritten.

PREFLIGHT

    if [ ! -t 0 ]; then
        echo "  [abort] Not an interactive shell — re-run with --yes to skip this prompt." >&2
        exit 1
    fi

    printf "  Type 'yes' to continue: "
    # `|| reply=""` because `set -e` would otherwise kill the script with a bare
    # exit 1 and no message when read hits EOF (Ctrl-D at the prompt).
    read -r reply || reply=""
    # tr rather than ${reply,,} — macOS ships bash 3.2, which lacks case expansion
    reply="$(printf '%s' "${reply}" | tr '[:upper:]' '[:lower:]')"
    if [ "${reply}" != "yes" ]; then
        echo "  Aborted. Nothing was changed."
        exit 1
    fi
    echo ""
fi

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
    bash "${DOTFILES_DIR}/utilities/scripts/setup-vscode.sh"
    echo ""
fi

# ============================================================
# BetterTouchTool preset import (requires socket server enabled)
# ============================================================
BTTCLI="/Applications/BetterTouchTool.app/Contents/SharedSupport/bin/bttcli"
BTT_PRESET="${DOTFILES_DIR}/bettertouchtool/kam_btt_presets.bttpreset"
if [ -x "${BTTCLI}" ] && [ -f "${BTT_PRESET}" ]; then
    echo "-> Importing BetterTouchTool preset..."
    if "${BTTCLI}" import_preset path="${BTT_PRESET}" 2>/dev/null; then
        echo "   Done."
    else
        echo "   [warn] Failed — ensure BTT is running with socket server enabled"
    fi
else
    echo "-> Skipping BetterTouchTool (bttcli or preset not found)"
fi
echo ""

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
