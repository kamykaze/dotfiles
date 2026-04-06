#!/bin/bash
# Toggle a Chrome app-mode window: show, hide, or create.
# Usage: chrome-app-toggle.sh <url> <profile_name> <title_match>
#
# Called from BetterTouchTool shortcuts. The profile_name (e.g. "work",
# "personal") is resolved to the correct Chrome profile directory at runtime.
#
# title_match is a string to find in the Chrome window title (e.g. "Monkeytype",
# "Google Sheets"). This is needed because Chrome's AppleScript API does not
# expose app-mode windows — we use System Events to find them by title instead.
#
# Toggle works by minimizing/restoring individual Chrome windows via System Events.
# A state file tracks whether the window was last minimized, since macOS reports
# minimized Chrome windows identically to visible ones via System Events.

set -e

URL="$1"
PROFILE_NAME="$2"
TITLE_MATCH="$3"

if [[ -z "${URL}" || -z "${PROFILE_NAME}" || -z "${TITLE_MATCH}" ]]; then
    echo "Usage: chrome-app-toggle.sh <url> <profile_name> <title_match>"
    exit 1
fi

CHROME_DIR="${HOME}/Library/Application Support/Google/Chrome"
STATE_DIR="${HOME}/.cache/chrome-app-toggle"
mkdir -p "${STATE_DIR}"

# State file tracks whether window is currently minimized
STATE_FILE="${STATE_DIR}/$(echo "${URL}" | md5 -q)"

# Resolve profile display name to directory name (e.g. "work" -> "Profile 2")
PROFILE_DIR=""
for prefs in "${CHROME_DIR}"/*/Preferences; do
    dir_name=$(basename "$(dirname "${prefs}")")
    name=$(python3 -c "
import json, sys
try:
    p = json.load(open(sys.argv[1]))
    print(p.get('profile', {}).get('name', ''))
except: pass
" "${prefs}" 2>/dev/null)
    if [[ "$(echo "${name}" | tr '[:upper:]' '[:lower:]')" == "$(echo "${PROFILE_NAME}" | tr '[:upper:]' '[:lower:]')" ]]; then
        PROFILE_DIR="${dir_name}"
        break
    fi
done

if [[ -z "${PROFILE_DIR}" ]]; then
    osascript -e "display dialog \"Chrome profile '${PROFILE_NAME}' not found.\" buttons {\"OK\"} default button \"OK\" with icon stop"
    exit 1
fi

# Check if window exists (visible or minimized) in System Events
WINDOW_EXISTS=$(osascript - "${TITLE_MATCH}" <<'APPLESCRIPT'
on run argv
    set titleMatch to item 1 of argv
    tell application "System Events" to tell process "Google Chrome"
        repeat with w in every window
            if name of w contains titleMatch then
                return "yes"
            end if
        end repeat
    end tell
    return "no"
end run
APPLESCRIPT
)

if [[ "${WINDOW_EXISTS}" == "yes" ]]; then
    if [[ -f "${STATE_FILE}" ]]; then
        # Window is minimized: restore it via Window menu
        osascript - "${TITLE_MATCH}" <<'APPLESCRIPT'
on run argv
    set titleMatch to item 1 of argv
    tell application "System Events" to tell process "Google Chrome"
        set windowMenu to menu "Window" of menu bar 1
        repeat with mi in every menu item of windowMenu
            set itemName to name of mi
            if itemName is not missing value then
                if itemName contains titleMatch then
                    click mi
                    set frontmost to true
                    exit repeat
                end if
            end if
        end repeat
    end tell
end run
APPLESCRIPT
        rm -f "${STATE_FILE}"
    else
        # Window is visible: minimize it
        osascript - "${TITLE_MATCH}" <<'APPLESCRIPT'
on run argv
    set titleMatch to item 1 of argv
    tell application "System Events" to tell process "Google Chrome"
        repeat with w in every window
            if name of w contains titleMatch then
                click (first button of w whose description is "minimize button")
                exit repeat
            end if
        end repeat
    end tell
end run
APPLESCRIPT
        touch "${STATE_FILE}"
    fi
else
    # Window doesn't exist: create it
    rm -f "${STATE_FILE}"
    open -na "Google Chrome" --args --app="${URL}" --profile-directory="${PROFILE_DIR}"
fi
