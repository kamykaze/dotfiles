#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"

echo "-> Setting up Launch Agents..."

mkdir -p "${LAUNCH_AGENTS_DIR}"

# ============================================================
# Kanata keyboard daemon
# ============================================================
KANATA_PLIST_SRC="${DOTFILES_DIR}/utilities/launchdaemons/com.github.jtroo.kanata.plist"
KANATA_PLIST_DEST="${LAUNCH_AGENTS_DIR}/com.github.jtroo.kanata.plist"
KANATA_RUNNER_SRC="${DOTFILES_DIR}/utilities/bin/kanata-runner.sh"
KANATA_RUNNER_DEST="${HOME}/bin/kanata-runner.sh"

if [ ! -f "${KANATA_PLIST_SRC}" ]; then
    echo "  [warn] Kanata plist not found at ${KANATA_PLIST_SRC}, skipping"
else
    # Ensure ~/bin exists and kanata-runner.sh is in place
    mkdir -p "${HOME}/bin"
    if [ ! -f "${KANATA_RUNNER_DEST}" ]; then
        cp "${KANATA_RUNNER_SRC}" "${KANATA_RUNNER_DEST}"
        chmod +x "${KANATA_RUNNER_DEST}"
        echo "  [copy] kanata-runner.sh -> ~/bin/"
    else
        echo "  [skip] ~/bin/kanata-runner.sh (already exists)"
    fi

    # Install the plist, substituting __USER__ with the real username
    if [ -f "${KANATA_PLIST_DEST}" ]; then
        echo "  [skip] Kanata LaunchAgent plist (already installed)"
    else
        sed "s/__USER__/$(whoami)/g" "${KANATA_PLIST_SRC}" > "${KANATA_PLIST_DEST}"
        chmod 644 "${KANATA_PLIST_DEST}"
        echo "  [copy] Kanata plist -> ~/Library/LaunchAgents/ (username: $(whoami))"
    fi

    # Load the agent (unload first to be safe/idempotent)
    echo "  Loading Kanata LaunchAgent..."
    launchctl unload "${KANATA_PLIST_DEST}" 2>/dev/null || true
    launchctl load "${KANATA_PLIST_DEST}"
    echo "  [ok] Kanata LaunchAgent loaded"

    echo ""
    echo "  NOTE: Kanata requires accessibility permissions."
    echo "  If it fails to start, grant access in:"
    echo "  System Settings -> Privacy & Security -> Accessibility"
fi

# ============================================================
# Dotfiles daily sync
# ============================================================
SYNC_PLIST_SRC="${DOTFILES_DIR}/utilities/launchdaemons/com.dotfiles.sync.plist"
SYNC_PLIST_DEST="${LAUNCH_AGENTS_DIR}/com.dotfiles.sync.plist"

if [ ! -f "${SYNC_PLIST_SRC}" ]; then
    echo "  [warn] Sync plist not found at ${SYNC_PLIST_SRC}, skipping"
else
    if [ -f "${SYNC_PLIST_DEST}" ]; then
        echo "  [skip] Dotfiles sync LaunchAgent (already installed)"
    else
        # Substitute __DOTFILES_DIR__ with the actual repo path
        sed "s|__DOTFILES_DIR__|${DOTFILES_DIR}|g" "${SYNC_PLIST_SRC}" > "${SYNC_PLIST_DEST}"
        chmod 644 "${SYNC_PLIST_DEST}"
        echo "  [copy] Dotfiles sync plist -> ~/Library/LaunchAgents/ (dir: ${DOTFILES_DIR})"
    fi

    launchctl unload "${SYNC_PLIST_DEST}" 2>/dev/null || true
    launchctl load "${SYNC_PLIST_DEST}"
    echo "  [ok] Dotfiles sync LaunchAgent loaded (runs daily)"
fi

echo "  Done."
