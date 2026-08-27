#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"

# --force syncs even from a machine that has not been fully provisioned yet.
# Without it, sections that could capture un-configured state are skipped —
# this script runs daily via LaunchAgent, so a silent bad sync is the real risk.
FORCE=0
for arg in "$@"; do
    case "${arg}" in
        --force) FORCE=1 ;;
        *) echo "Unknown option: ${arg}" >&2; exit 64 ;;
    esac
done

echo "-> Syncing configs into dotfiles repo..."

changed=0

# Update a single `defaults write` value in macos.sh to match the live system.
# Usage: sync_default DOMAIN KEY TYPE
#   DOMAIN: plist domain, or "NSGlobalDomain" / "-g" for global
#   KEY:    defaults key (e.g. "Clicking")
#   TYPE:   float | int | bool
sync_default() {
    local domain="$1"
    local key="$2"
    local type="$3"
    local macos_sh="${DOTFILES_DIR}/scripts/macos.sh"

    # Read from global domain using -g flag
    local read_args=("${domain}" "${key}")
    [ "${domain}" = "NSGlobalDomain" ] && read_args=("-g" "${key}")

    local value
    value=$(defaults read "${read_args[@]}" 2>/dev/null) || return 0

    # Normalise bool: 0->false, 1->true
    local write_value="${value}"
    if [ "${type}" = "bool" ]; then
        [ "${value}" = "1" ] && write_value="true" || write_value="false"
    fi

    # Check what value macos.sh currently has for this key
    local escaped_key
    escaped_key=$(printf '%s' "${key}" | sed 's/[]\/$*.^[]/\\&/g')
    local current
    current=$(grep -m1 "${escaped_key} -${type} " "${macos_sh}" \
        | grep -oE "\-${type} [^ ]+" | awk '{print $2}' || true)

    if [ "${current}" != "${write_value}" ]; then
        # Replace old value with new value on every matching line
        sed -i '' "s/\(${escaped_key} -${type} \)[^ ]*/\1${write_value}/g" "${macos_sh}"
        echo "  [update] ${key}: ${current:-?} -> ${write_value}"
        changed=1
    fi
}

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
# VS Code settings / keybindings snapshots
# Settings Sync owns the live files; these are read-only snapshots for reference
# and cold-start diffing. Never symlinked back — that breaks Settings Sync.
# ============================================================
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
sync_file "${VSCODE_USER_DIR}/settings.json" \
          "${DOTFILES_DIR}/_configs/vscode-settings.json" "VS Code settings"
sync_file "${VSCODE_USER_DIR}/keybindings.json" \
          "${DOTFILES_DIR}/_configs/vscode-keybindings.json" "VS Code keybindings"

# ============================================================
# VS Code extensions list
# ============================================================
if command -v code &>/dev/null; then
    EXTENSIONS_FILE="${DOTFILES_DIR}/_configs/vscode-extensions.txt"
    NEW_LIST="$(code --list-extensions 2>/dev/null | sort)"
    OLD_LIST="$(sort "${EXTENSIONS_FILE}" 2>/dev/null || echo "")"
    REMOVED="$(comm -23 <(echo "${OLD_LIST}") <(echo "${NEW_LIST}"))"

    if [ "${NEW_LIST}" = "${OLD_LIST}" ]; then
        echo "  [skip] VS Code extensions (unchanged)"
    elif [ -n "${REMOVED}" ] && [ "${FORCE}" -eq 0 ]; then
        # A missing extension usually means it has not finished installing yet
        # (an aborted brew bundle, Settings Sync mid-flight) rather than a
        # deliberate uninstall. Record additions, but keep the missing ones so a
        # half-provisioned machine cannot quietly shrink the list. --force to drop them.
        UNION="$(printf '%s\n%s\n' "${OLD_LIST}" "${NEW_LIST}" | sed '/^$/d' | sort -u)"
        if [ "${UNION}" != "${OLD_LIST}" ]; then
            echo "${UNION}" > "${EXTENSIONS_FILE}"
            echo "  [copy] VS Code extensions list (additions only)"
            changed=1
        else
            echo "  [skip] VS Code extensions (nothing to add)"
        fi
        echo "         kept, not installed here — use --force to drop:"
        echo "${REMOVED}" | sed 's/^/           - /'
    else
        echo "${NEW_LIST}" > "${EXTENSIONS_FILE}"
        echo "  [copy] VS Code extensions list"
        changed=1
    fi
else
    echo "  [skip] VS Code extensions ('code' CLI not found)"
fi

# ============================================================
# BetterTouchTool preset export (requires socket server enabled)
# ============================================================
BTTCLI="/Applications/BetterTouchTool.app/Contents/SharedSupport/bin/bttcli"
BTT_PRESET="${DOTFILES_DIR}/bettertouchtool/kam_btt_presets.bttpreset"
if [ -x "${BTTCLI}" ]; then
    BTT_EXPORT_TMP="${BTT_PRESET}.tmp"
    if "${BTTCLI}" export_preset name=kam_btt_presets "outputPath=${BTT_EXPORT_TMP}" includeSettings=true compress=false 2>/dev/null; then
        # bttcli returns before the file is fully written — wait briefly
        for _ in 1 2 3 4 5; do [ -f "${BTT_EXPORT_TMP}" ] && break; sleep 1; done
        # BTT generates a new BTTPresetUUID on every export; strip it before comparing
        btt_strip_uuid() { grep -v '"BTTPresetUUID"' "$1"; }
        if diff -q <(btt_strip_uuid "${BTT_EXPORT_TMP}") <(btt_strip_uuid "${BTT_PRESET}") &>/dev/null; then
            rm -f "${BTT_EXPORT_TMP}"
            echo "  [skip] BetterTouchTool preset (unchanged)"
        else
            mv "${BTT_EXPORT_TMP}" "${BTT_PRESET}"
            echo "  [copy] BetterTouchTool preset"
            changed=1
        fi
    else
        rm -f "${BTT_EXPORT_TMP}"
        echo "  [skip] BetterTouchTool (socket server not enabled or BTT not running)"
    fi
else
    echo "  [skip] BetterTouchTool (bttcli not found)"
fi

# ============================================================
# Claude Desktop — SKIPPED (contains API keys)
# Edit _configs/claude_desktop_config.json.template manually.
# ============================================================
echo "  [skip] Claude Desktop config (sensitive — edit .template manually)"

# ============================================================
# macOS system preferences -> scripts/macos.sh
# Reads live defaults and updates the values in macos.sh in-place.
# Add new settings here whenever you add a defaults write to macos.sh.
# ============================================================
if [ ! -f "${STATE_DIR}/macos-applied" ] && [ "${FORCE}" -eq 0 ]; then
    echo "-> Skipping macOS preferences — scripts/macos.sh has never been applied here."
    echo "   Syncing now would overwrite every curated value with this machine's"
    echo "   factory defaults. Run 'bash scripts/macos.sh' first, or pass --force."
else

echo "-> Syncing macOS preferences into scripts/macos.sh..."

# Trackpad — tracking & click
sync_default "-g"                                    "com.apple.trackpad.scaling"               "float"
sync_default "com.apple.AppleMultitouchTrackpad"     "FirstClickThreshold"                      "int"
sync_default "com.apple.AppleMultitouchTrackpad"     "SecondClickThreshold"                     "int"
sync_default "com.apple.AppleMultitouchTrackpad"     "Clicking"                                 "bool"
sync_default "com.apple.AppleMultitouchTrackpad"     "ForceSuppressed"                          "bool"
sync_default "com.apple.AppleMultitouchTrackpad"     "ActuationStrength"                        "int"
sync_default "com.apple.AppleMultitouchTrackpad"     "TrackpadRightClick"                       "bool"
sync_default "com.apple.AppleMultitouchTrackpad"     "TrackpadCornerSecondaryClick"             "int"

# Trackpad — scroll & gestures
# Note: gesture settings are read from the bluetooth domain (authoritative for built-in trackpad).
# The sed in sync_default uses /g so it updates both domain lines in macos.sh.
sync_default "NSGlobalDomain"                                        "com.apple.swipescrolldirection"             "bool"
sync_default "NSGlobalDomain"                                        "AppleEnableSwipeNavigateWithScrolls"        "bool"
sync_default "com.apple.driver.AppleBluetoothMultitouch.trackpad"   "TrackpadPinch"                              "bool"
sync_default "com.apple.driver.AppleBluetoothMultitouch.trackpad"   "TrackpadTwoFingerDoubleTapGesture"          "bool"
sync_default "com.apple.driver.AppleBluetoothMultitouch.trackpad"   "TrackpadRotate"                             "bool"
sync_default "com.apple.driver.AppleBluetoothMultitouch.trackpad"   "TrackpadThreeFingerTapGesture"              "int"
sync_default "com.apple.driver.AppleBluetoothMultitouch.trackpad"   "TrackpadThreeFingerHorizSwipeGesture"       "int"
sync_default "com.apple.driver.AppleBluetoothMultitouch.trackpad"   "TrackpadThreeFingerVertSwipeGesture"        "int"
sync_default "com.apple.driver.AppleBluetoothMultitouch.trackpad"   "TrackpadFourFingerHorizSwipeGesture"        "int"
sync_default "com.apple.driver.AppleBluetoothMultitouch.trackpad"   "TrackpadFourFingerVertSwipeGesture"         "int"
sync_default "com.apple.driver.AppleBluetoothMultitouch.trackpad"   "TrackpadFourFingerPinchGesture"             "bool"
sync_default "com.apple.driver.AppleBluetoothMultitouch.trackpad"   "TrackpadFiveFingerPinchGesture"             "bool"
sync_default "com.apple.driver.AppleBluetoothMultitouch.trackpad"   "TrackpadTwoFingerFromRightEdgeSwipeGesture" "int"

# Dock
sync_default "com.apple.dock"                        "mineffect"                                "string"

# Keyboard
sync_default "NSGlobalDomain"                        "KeyRepeat"                                "int"
sync_default "NSGlobalDomain"                        "InitialKeyRepeat"                         "int"

fi

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
