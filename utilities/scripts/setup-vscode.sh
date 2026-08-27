#!/usr/bin/env bash
# VS Code — status check only. This script deliberately DOES NOT touch
# ~/Library/Application Support/Code/User/.
#
# VS Code config is owned by built-in Settings Sync (GitHub account):
#   - settings.json / keybindings.json  -> Settings Sync
#   - extensions                        -> Settings Sync, plus the `vscode "..."`
#                                          entries in the Brewfile for a cold install
#
# The `_configs/vscode-*.json` files in this repo are read-only SNAPSHOTS refreshed
# by scripts/sync.sh. They are NOT symlinked into place: symlinking them fights
# Settings Sync, which overwrites the file and silently drops newer synced changes.

set -e

VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "-> Checking VS Code configuration..."
echo "   settings.json / keybindings.json / extensions are managed by Settings Sync."

if [ ! -d "${VSCODE_USER_DIR}" ]; then
    echo "   [skip] VS Code has not run yet — sign in and enable Settings Sync on first launch."
    exit 0
fi

# Warn about symlinks left behind by older versions of this script, which break
# Settings Sync. Left for the user to remove so no synced state is discarded silently.
for name in settings keybindings; do
    target="${VSCODE_USER_DIR}/${name}.json"
    if [ -L "${target}" ] && [[ "$(readlink "${target}")" == "${DOTFILES_DIR}"/* ]]; then
        echo "   [warn] ${name}.json is symlinked into this repo — this breaks Settings Sync."
        echo "          Fix with:  rm \"${target}\""
        echo "          then restart VS Code and let Settings Sync restore it."
    fi
done

echo "   Done."
