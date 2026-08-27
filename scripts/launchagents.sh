#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"

echo "-> Setting up Launch Agents..."

mkdir -p "${LAUNCH_AGENTS_DIR}"

# ============================================================
# Kanata keyboard daemon (LaunchDaemon — runs as root)
# ============================================================
KANATA_PLIST_SRC="${DOTFILES_DIR}/utilities/launchdaemons/com.github.jtroo.kanata.plist"
KANATA_PLIST_DEST="/Library/LaunchDaemons/com.github.jtroo.kanata.plist"
KANATA_RUNNER_SRC="${DOTFILES_DIR}/utilities/bin/kanata-runner.sh"
KANATA_RUNNER_DEST="${HOME}/bin/kanata-runner.sh"
KANATA_CONFIG="${DOTFILES_DIR}/_configs/kanata.kbd"
KANATA_PRIVATE="${DOTFILES_DIR}/_configs/kanata-private.kbd"

# kanata.kbd does `(include kanata-private.kbd)`, and that file is gitignored, so
# it is always absent on a fresh clone. Without it the config does not parse and
# the daemon crash-loops invisibly (KeepAlive respawns it forever). Seed it from
# the template so kanata runs, and say loudly that the values are placeholders.
if [ ! -f "${KANATA_PRIVATE}" ] && [ -f "${KANATA_PRIVATE}.template" ]; then
    cp "${KANATA_PRIVATE}.template" "${KANATA_PRIVATE}"
    echo "  [copy] kanata-private.kbd created from template"
    echo "  [ACTION NEEDED] Edit _configs/kanata-private.kbd — the email macros"
    echo "                  are placeholders (example.com) until you do."
fi

if [ ! -f "${KANATA_PLIST_SRC}" ]; then
    echo "  [warn] Kanata plist not found at ${KANATA_PLIST_SRC}, skipping"
else
    # Ensure ~/bin exists and kanata-runner.sh is in place (substitute __USER__)
    # Always overwrite since it's generated from a template
    mkdir -p "${HOME}/bin"
    sed "s/__USER__/$(whoami)/g" "${KANATA_RUNNER_SRC}" > "${KANATA_RUNNER_DEST}"
    chmod +x "${KANATA_RUNNER_DEST}"
    echo "  [copy] kanata-runner.sh -> ~/bin/"

    # Install the plist to /Library/LaunchDaemons/ (requires sudo, must be root:wheel)
    if [ -f "${KANATA_PLIST_DEST}" ]; then
        echo "  [skip] Kanata LaunchDaemon plist (already installed)"
    else
        sed "s/__USER__/$(whoami)/g" "${KANATA_PLIST_SRC}" | sudo tee "${KANATA_PLIST_DEST}" > /dev/null
        sudo chown root:wheel "${KANATA_PLIST_DEST}"
        sudo chmod 644 "${KANATA_PLIST_DEST}"
        echo "  [copy] Kanata plist -> /Library/LaunchDaemons/ (username: $(whoami))"
    fi

    # Validate the config before loading. The daemon has KeepAlive set, so a
    # config error turns into an invisible respawn loop that only shows up as a
    # growing /tmp/kanata.log — fail loudly here instead.
    if command -v kanata &>/dev/null && ! kanata -c "${KANATA_CONFIG}" --check &>/dev/null; then
        echo "  [warn] kanata config does not parse — NOT loading the daemon."
        kanata -c "${KANATA_CONFIG}" --check 2>&1 | grep -vE "^\S+ .*(INFO|starting)" | sed 's/^/         /'
        echo "         Fix the config, then re-run: bash scripts/launchagents.sh"
    else
        # Load the daemon (unload first to be safe/idempotent)
        echo "  Loading Kanata LaunchDaemon..."
        sudo launchctl unload "${KANATA_PLIST_DEST}" 2>/dev/null || true
        sudo launchctl load "${KANATA_PLIST_DEST}"
        echo "  [ok] Kanata LaunchDaemon loaded"
    fi

    # Loading the daemon says nothing about whether kanata survived. The common
    # failure is a missing TCC grant, which only shows up in the log — so look.
    if command -v kanata &>/dev/null && [ -f "${KANATA_PLIST_DEST}" ]; then
        sleep 4
        if pgrep -x kanata >/dev/null 2>&1; then
            echo "  [ok] kanata is running"
        else
            # Scope every match to the MOST RECENT run. /tmp/kanata.log accumulates
            # across a crash loop, so grepping the whole file matches gates already
            # cleared — and the current failure may be a WARN with no ERROR line at
            # all, leaving a stale ERROR as the newest one.
            RUN_LOG="$(awk '/kanata v[0-9][^ ]* starting/{buf=""} {buf = buf $0 "\n"} END{printf "%s", buf}' /tmp/kanata.log 2>/dev/null)"
            LAST_ERR="$(printf '%s' "${RUN_LOG}" | grep -a "ERROR" | tail -1)"

            echo ""
            echo "  [warn] kanata is NOT running. From the latest run in /tmp/kanata.log:"
            if [ -n "${LAST_ERR}" ]; then
                printf '%s\n' "${LAST_ERR}" | sed 's/^/         /'
            else
                printf '%s' "${RUN_LOG}" | tail -3 | sed 's/^/         /'
            fi

            PERM=""
            case "${RUN_LOG}" in
                *"needs macOS Input Monitoring"*) PERM="Input Monitoring" ;;
                *"needs macOS Accessibility"*)    PERM="Accessibility" ;;
            esac

            if [ -n "${PERM}" ]; then
                echo ""
                echo "  ACTION: System Settings -> Privacy & Security -> ${PERM}"
                echo "          Enable 'kanata'. If it is not listed, add it with + and"
                echo "          Cmd+Shift+G -> /opt/homebrew/bin/kanata"
                echo ""
                echo "          kanata needs BOTH Input Monitoring and Accessibility, and"
                echo "          only reports the next missing one — expect to grant the"
                echo "          other after this. KeepAlive restarts it within seconds."
            elif printf '%s' "${RUN_LOG}" | grep -aqE "connect_failed|output backend (not ready|unavailable)"; then
                # kanata grabbed the keyboard but has no virtual keyboard to write
                # to: typing works, mappings don't. Almost always a driver version
                # kanata does not support.
                echo ""
                echo "  ACTION: kanata has no output backend — the Karabiner driver"
                echo "          version is probably wrong. Run:"
                echo "            bash scripts/karabiner-driver.sh"
            else
                echo "         See SETUP_NOTES.md section 7 for the full checklist."
            fi
        fi
    fi
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
