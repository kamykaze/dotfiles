#!/bin/bash
# Focus a Chrome tab by URL and title, or open it if not found.
# Usage: chrome-tab-focus.sh <url> <profile_name> <title_match>
#
# Called from BetterTouchTool shortcuts. The profile_name (e.g. "work",
# "personal") is resolved to the correct Chrome profile directory at runtime.
#
# title_match disambiguates tabs with the same URL across profiles
# (e.g. two Gmail tabs: "Cuker Mail" vs "kamykaze@gmail.com").
#
# If the tab exists, it is focused instantly via Chrome's AppleScript API.
# If not, the URL is opened as a new tab in the matching profile.

set -e

URL="$1"
PROFILE_NAME="$2"
TITLE_MATCH="$3"

if [[ -z "${URL}" || -z "${PROFILE_NAME}" || -z "${TITLE_MATCH}" ]]; then
    echo "Usage: chrome-app-toggle.sh <url> <profile_name> <title_match>"
    exit 1
fi

# Strip URL fragment for more reliable matching
MATCH_URL="${URL%%#*}"

# Search all Chrome tabs and focus the matching one
RESULT=$(osascript - "${MATCH_URL}" "${TITLE_MATCH}" <<'APPLESCRIPT'
on run argv
    set targetURL to item 1 of argv
    set titleMatch to item 2 of argv
    tell application "Google Chrome"
        set windowCount to count of windows
        repeat with w from 1 to windowCount
            set tabCount to count of tabs of window w
            repeat with t from 1 to tabCount
                set tabURL to URL of tab t of window w
                set tabTitle to title of tab t of window w
                if tabURL contains targetURL and tabTitle contains titleMatch then
                    set active tab index of window w to t
                    set index of window w to 1
                    activate
                    return "found"
                end if
            end repeat
        end repeat
    end tell
    return "not_found"
end run
APPLESCRIPT
)

if [[ "${RESULT}" == "found" ]]; then
    exit 0
fi

# Tab not found — resolve profile and open URL
CHROME_DIR="${HOME}/Library/Application Support/Google/Chrome"
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

open -na "Google Chrome" --args --profile-directory="${PROFILE_DIR}" "${URL}"
