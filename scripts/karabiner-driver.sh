#!/usr/bin/env bash
set -e

# ============================================================
# Karabiner-DriverKit-VirtualHIDDevice — the virtual keyboard kanata writes to.
#
# kanata talks to the driver over a UNIX socket using a wire protocol tied to the
# driver's MAJOR version. Get the major wrong and kanata starts, grabs the
# keyboard, finds no output backend, and releases it again — so typing still
# works but no mappings apply, with only `connect_failed asio.system:2` in
# /tmp/kanata.log to go on.
#
#   driver 6.x -> protocol-5 -> kanata <= 1.12.0   <- what we want
#   driver 8.x -> protocol-7 -> kanata `main` only; no release ships it yet
#
# Point releases WITHIN 6.x are interchangeable, so match on the major only.
# kanata 1.11.0 and 1.12.0 both name v6.2.0 in their release notes, but 6.8.0
# (what Karabiner-Elements 15.9.0 installs) logs `driver version matched: true`
# and works fine. The old exact-equality check flagged that healthy setup as
# broken and told the user to downgrade.
#
# When a kanata release finally lands jtroo/kanata#2123 ("feat(macos): support
# VirtualHIDDevice v8", merged 2026-07-28, after v1.12.1-prerelease-1), bump
# REQUIRED_MAJOR to 8 and move BOTH at once — upstream is explicit that the
# driver and kanata upgrade as a pair.
#   kanata release notes: https://github.com/jtroo/kanata/releases
#
# The driver is NOT installed via `cask "karabiner-elements"`. That cask is
# `auto_updates`, so Homebrew cannot hold it back, and Karabiner-Elements 16.1.0
# ships driver 8.0.0. Karabiner does not install that on its own — Sparkle only
# checks and prompts — but accepting the prompt once is enough to break every
# mapping, so the bottom of this script removes the prompt.
# ============================================================

REQUIRED_MAJOR="6"
FALLBACK_VERSION="6.2.0"   # only used when NO driver is installed at all
PKG_URL="https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/download/v${FALLBACK_VERSION}/Karabiner-DriverKit-VirtualHIDDevice-${FALLBACK_VERSION}.pkg"

DRIVER_ROOT="/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice"
DAEMON_PLIST="${DRIVER_ROOT}/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/Info.plist"
MANAGER="/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager"
KE_APP="/Applications/Karabiner-Elements.app"

installed_version() {
    [ -f "${DAEMON_PLIST}" ] || return 1
    plutil -extract CFBundleShortVersionString raw "${DAEMON_PLIST}" 2>/dev/null
}

app_version() {
    [ -d "${KE_APP}" ] || return 1
    plutil -extract CFBundleShortVersionString raw "${KE_APP}/Contents/Info.plist" 2>/dev/null
}

# ============================================================
# 1. Driver major version
# ============================================================
echo "-> Checking Karabiner virtual HID driver (kanata needs v${REQUIRED_MAJOR}.x)..."

INSTALLED="$(installed_version || true)"

if [ -z "${INSTALLED}" ]; then
    echo "   No driver installed. Installing v${FALLBACK_VERSION}..."
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "${TMP_DIR}"' EXIT
    PKG="${TMP_DIR}/Karabiner-DriverKit-VirtualHIDDevice-${FALLBACK_VERSION}.pkg"

    if curl -fsSL -o "${PKG}" "${PKG_URL}"; then
        sudo installer -pkg "${PKG}" -target / >/dev/null
        echo "  [ok] driver v${FALLBACK_VERSION} installed"
        if [ -x "${MANAGER}" ]; then
            sudo "${MANAGER}" forceActivate || true
            echo "  [ok] driver activation requested"
        fi
        echo ""
        echo "  ACTION: approve the driver in System Settings -> General -> Login Items"
        echo "          & Extensions -> Driver Extensions, then reboot."
        echo "          Verify with: systemextensionsctl list"
    else
        echo "  [warn] download failed: ${PKG_URL}"
        echo "         Install it by hand, then re-run this script."
    fi
elif [ "${INSTALLED%%.*}" = "${REQUIRED_MAJOR}" ]; then
    echo "  [skip] driver v${INSTALLED} is in the v${REQUIRED_MAJOR}.x line — compatible"
else
    # Swapping majors means deactivating the current driver, a reboot, and a GUI
    # approval afterwards. Too involved to do behind the user's back.
    echo "  [warn] driver v${INSTALLED} installed, but kanata needs v${REQUIRED_MAJOR}.x."
    echo "         kanata will run but NO mappings will apply. To go back to v${REQUIRED_MAJOR}.x:"
    echo ""
    echo "           sudo '${MANAGER}' deactivate"
    echo "           brew uninstall --cask karabiner-elements   # if still installed"
    echo "           curl -LO ${PKG_URL}"
    echo "           sudo installer -pkg Karabiner-DriverKit-VirtualHIDDevice-${FALLBACK_VERSION}.pkg -target /"
    echo "           sudo '${MANAGER}' forceActivate"
    echo ""
    echo "         Approve in System Settings -> General -> Login Items & Extensions"
    echo "         -> Driver Extensions, then reboot."
    echo ""
    echo "         Alternatively, once a kanata release includes jtroo/kanata#2123,"
    echo "         upgrade kanata instead and set REQUIRED_MAJOR=8 in this script."
fi

# ============================================================
# 2. Silence Karabiner-Elements update prompts
#
# Karabiner-Elements checks for updates on startup and prompts you to install
# them. It does NOT update itself, and it does not go through Homebrew. But
# 16.1.0 replaces the driver with 8.0.0 and kills every mapping, so one accepted
# prompt is all it takes.
#
# The switch lives in Karabiner's own config, NOT in a Sparkle `defaults` domain
# (SUEnableAutomaticChecks is never written — checked, it does not exist). It is
# the same flag as Settings -> Misc -> "Check for updates on startup".
#
# Clicking "Skip This Version" on the prompt is NOT enough: that only records
# SUSkippedVersion for that one release, so the next one prompts again.
# ============================================================
KARABINER_JSON="${HOME}/.config/karabiner/karabiner.json"

if [ -d "${KE_APP}" ]; then
    echo "-> Silencing Karabiner-Elements update prompts..."

    KE_VERSION="$(app_version || echo "unknown")"
    if [ "${KE_VERSION%%.*}" -ge 16 ] 2>/dev/null; then
        echo "  [warn] Karabiner-Elements ${KE_VERSION} is installed — 16.x ships driver 8.x."
        echo "         That is almost certainly why mappings stopped working."
    else
        echo "  [ok] Karabiner-Elements ${KE_VERSION} (pre-16, ships a v${REQUIRED_MAJOR}.x driver)"
    fi

    if [ ! -f "${KARABINER_JSON}" ]; then
        echo "  [skip] ${KARABINER_JSON} not found — launch Karabiner-Elements once first"
    else
        # Read/modify/write in python so the rest of the config is preserved byte
        # for byte. Exit 0 = already disabled, 1 = changed it, 2 = failed.
        set +e
        python3 - "${KARABINER_JSON}" <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path) as f:
        cfg = json.load(f)
except Exception as e:
    print(f"    could not parse: {e}")
    sys.exit(2)
g = cfg.setdefault("global", {})
if g.get("check_for_updates_on_startup") is False:
    sys.exit(0)
g["check_for_updates_on_startup"] = False
try:
    with open(path, "w") as f:
        json.dump(cfg, f, indent=4)
        f.write("\n")
except Exception as e:
    print(f"    could not write: {e}")
    sys.exit(2)
sys.exit(1)
PY
        rc=$?
        set -e
        case "${rc}" in
            0) echo "  [skip] update checks already disabled" ;;
            1) echo "  [ok] set check_for_updates_on_startup=false in karabiner.json"
               echo "       Karabiner-Elements rewrites this file, so quit and reopen it"
               echo "       if it is running, then confirm under Settings -> Misc." ;;
            *) echo "  [warn] could not update ${KARABINER_JSON}"
               echo "         Turn it off by hand: Settings -> Misc ->"
               echo "         uncheck \"Check for updates on startup\"" ;;
        esac
    fi
else
    echo "  [skip] Karabiner-Elements not installed (no updater to silence)"
fi
