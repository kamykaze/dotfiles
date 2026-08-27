#!/usr/bin/env bash
set -e

# ============================================================
# Karabiner-DriverKit-VirtualHIDDevice — the virtual keyboard kanata writes to.
#
# kanata pins ONE driver version per release and talks to it over a UNIX socket
# whose path changed between driver majors. Get this wrong and kanata starts,
# grabs the keyboard, finds no output backend, and releases the keyboard again —
# so typing works but no mappings apply, with only `connect_failed asio.system:2`
# in /tmp/kanata.log to go on.
#
# This is NOT installed via `cask "karabiner-elements"`. That cask is
# `auto_updates`, so Homebrew will not hold it back, and Karabiner-Elements
# shipped driver 8.0.0 while kanata 1.12.0 still requires 6.2.0. Pin it here
# instead, and bump REQUIRED_VERSION when kanata's release notes change it.
#   kanata release notes: https://github.com/jtroo/kanata/releases
# ============================================================

REQUIRED_VERSION="6.2.0"   # kanata 1.12.0: "The supported Karabiner driver version in this release is v6.2.0"
PKG_URL="https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/download/v${REQUIRED_VERSION}/Karabiner-DriverKit-VirtualHIDDevice-${REQUIRED_VERSION}.pkg"

DRIVER_ROOT="/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice"
DAEMON_PLIST="${DRIVER_ROOT}/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/Info.plist"
MANAGER="/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager"

echo "-> Checking Karabiner virtual HID driver (kanata needs v${REQUIRED_VERSION})..."

installed_version() {
    [ -f "${DAEMON_PLIST}" ] || return 1
    plutil -extract CFBundleShortVersionString raw "${DAEMON_PLIST}" 2>/dev/null
}

INSTALLED="$(installed_version || true)"

if [ "${INSTALLED}" = "${REQUIRED_VERSION}" ]; then
    echo "  [skip] driver v${INSTALLED} already installed"
    exit 0
fi

if [ -n "${INSTALLED}" ]; then
    # Replacing a driver means deactivating the current one, which needs a reboot
    # and a GUI approval afterwards. Too involved to do behind the user's back.
    echo "  [warn] driver v${INSTALLED} installed, but kanata needs v${REQUIRED_VERSION}."
    echo "         kanata will run but no mappings will apply. To fix:"
    echo ""
    echo "           sudo '${MANAGER}' deactivate"
    echo "           brew uninstall --cask karabiner-elements   # if still installed"
    echo "           curl -LO ${PKG_URL}"
    echo "           sudo installer -pkg Karabiner-DriverKit-VirtualHIDDevice-${REQUIRED_VERSION}.pkg -target /"
    echo "           sudo '${MANAGER}' forceActivate"
    echo ""
    echo "         Approve in System Settings -> General -> Login Items & Extensions"
    echo "         -> Driver Extensions, then reboot."
    exit 0
fi

# Nothing installed — safe to do the whole thing unattended.
echo "  Installing driver v${REQUIRED_VERSION}..."
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT
PKG="${TMP_DIR}/Karabiner-DriverKit-VirtualHIDDevice-${REQUIRED_VERSION}.pkg"

if ! curl -fsSL -o "${PKG}" "${PKG_URL}"; then
    echo "  [warn] download failed: ${PKG_URL}"
    echo "         Install it by hand, then re-run this script."
    exit 0
fi

sudo installer -pkg "${PKG}" -target / >/dev/null
echo "  [ok] driver v${REQUIRED_VERSION} installed"

if [ -x "${MANAGER}" ]; then
    sudo "${MANAGER}" forceActivate || true
    echo "  [ok] driver activation requested"
fi

echo ""
echo "  ACTION: approve the driver in System Settings -> General -> Login Items"
echo "          & Extensions -> Driver Extensions, then reboot."
echo "          Verify with: systemextensionsctl list"
