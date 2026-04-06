#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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
# macOS system preferences -> scripts/macos.sh
# Reads live defaults and updates the values in macos.sh in-place.
# Add new settings here whenever you add a defaults write to macos.sh.
# ============================================================
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

# Keyboard
sync_default "NSGlobalDomain"                        "KeyRepeat"                                "int"
sync_default "NSGlobalDomain"                        "InitialKeyRepeat"                         "int"

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
