#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "-> Syncing configs into dotfiles repo..."

changed=0

sync_file() {
    local src="$1"
    local dest="$2"
    local label="$3"

    if [ ! -f "${src}" ]; then
        echo "  [skip] ${label} (not found at ${src})"
        return
    fi

    if cmp -s "${src}" "${dest}" 2>/dev/null; then
        echo "  [skip] ${label} (unchanged)"
    else
        cp "${src}" "${dest}"
        echo "  [copy] ${label}"
        changed=1
    fi
}

# ============================================================
# iTerm2
# ============================================================
sync_file \
    "${HOME}/Library/Preferences/com.googlecode.iterm2.plist" \
    "${DOTFILES_DIR}/_configs/com.googlecode.iterm2.plist" \
    "iTerm2 preferences"

# ============================================================
# Karabiner-Elements
# ============================================================
sync_file \
    "${HOME}/.config/karabiner/karabiner.json" \
    "${DOTFILES_DIR}/_configs/karabiner.json" \
    "Karabiner config"

# ============================================================
# VS Code extensions list
# ============================================================
if command -v code &>/dev/null; then
    EXTENSIONS_FILE="${DOTFILES_DIR}/_configs/vscode-extensions.txt"
    NEW_LIST="$(code --list-extensions 2>/dev/null | sort)"
    OLD_LIST="$(sort "${EXTENSIONS_FILE}" 2>/dev/null || echo "")"
    if [ "${NEW_LIST}" = "${OLD_LIST}" ]; then
        echo "  [skip] VS Code extensions (unchanged)"
    else
        echo "${NEW_LIST}" > "${EXTENSIONS_FILE}"
        echo "  [copy] VS Code extensions list"
        changed=1
    fi
else
    echo "  [skip] VS Code extensions ('code' CLI not found)"
fi

# ============================================================
# Claude Desktop — SKIPPED (contains API keys)
# Edit _configs/claude_desktop_config.json.template manually.
# ============================================================
echo "  [skip] Claude Desktop config (sensitive — edit .template manually)"

# ============================================================
# Summary
# ============================================================
echo ""
if [ "${changed}" -eq 1 ]; then
    echo "-> Changes detected:"
    cd "${DOTFILES_DIR}"
    git diff --stat HEAD 2>/dev/null || git status --short
    echo ""
    echo "   Review the diff above, then commit when ready:"
    echo "   git add -p && git commit -m 'chore: sync configs'"
else
    echo "-> No changes. Repo is up to date."
fi
