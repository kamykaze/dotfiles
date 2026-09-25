#!/usr/bin/env bash
# Import bettertouchtool/kam_btt_presets.bttpreset into BetterTouchTool.
#
# Split out of install.sh for three reasons, all of which cost real time once:
#
#   1. bttcli lies. `import_preset` prints "done" and exits 0 when it imported
#      nothing at all — the import raises a confirmation sheet in the GUI, and
#      an unanswered sheet is reported as success after a 30s timeout. A whole
#      debugging session went into a preset that was never imported, because
#      the exit code said it was. Nothing here trusts bttcli's return value;
#      the import is proved by reading BTT's state back.
#   2. The import is also the counterpart to the export in sync.sh, which has
#      a guard against dropping triggers. The import direction can drop just as
#      much and had no guard at all.
#   3. install.sh is a bootstrap. Re-importing a preset is a routine thing to
#      want on its own, and it should not require running Homebrew, the kanata
#      driver pin and a launchd reinstall to get at it.
#
# Usage:
#   scripts/btt-import.sh            import, with the safety checks
#   scripts/btt-import.sh --force    import even if live triggers would be lost
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BTTCLI="/Applications/BetterTouchTool.app/Contents/SharedSupport/bin/bttcli"
BTT_PRESET="${DOTFILES_DIR}/bettertouchtool/kam_btt_presets.bttpreset"
BTT_SUPPORT="${HOME}/Library/Application Support/BetterTouchTool"
PRESET_NAME="kam_btt_presets"

FORCE=0
for arg in "$@"; do
    case "${arg}" in
        -f|--force) FORCE=1 ;;
        -h|--help)
            echo "Usage: scripts/btt-import.sh [-f|--force]"
            echo "  -f, --force   Import even if it would drop triggers BTT currently has"
            exit 0
            ;;
        *) echo "Unknown option: ${arg}" >&2; exit 64 ;;
    esac
done

echo "-> Importing BetterTouchTool preset..."

# ------------------------------------------------------------
# Preconditions
# ------------------------------------------------------------
if [ ! -x "${BTTCLI}" ] || [ ! -f "${BTT_PRESET}" ]; then
    echo "   [skip] bttcli or preset not found — nothing to do."
    exit 0
fi

if ! pgrep -x BetterTouchTool >/dev/null 2>&1; then
    echo "   [warn] BetterTouchTool is not running — start it and re-run."
    exit 1
fi

# The socket server lives in BTT's own prefs, not in the preset, so it has to be
# enabled by hand on every new machine (SETUP_NOTES.md section 3). Without it
# every command below fails in the same silent way, so say so plainly up front.
if [ "$(defaults read com.hegenberg.BetterTouchTool BTTSocketServerEnabled 2>/dev/null || echo 0)" != "1" ]; then
    echo "   [warn] BTT's socket server is disabled."
    echo "          Settings -> Scripting -> Command Line / Socket Server, then restart BTT."
    exit 1
fi

TMPDIR_BTT="$(mktemp -d)"
trap 'rm -rf "${TMPDIR_BTT}"' EXIT

# ------------------------------------------------------------
# Read BTT's current state, and keep it as a backup.
# ------------------------------------------------------------
# bttcli returns before the file is on disk, so every export here polls for it
# rather than trusting the call to have finished.
btt_export() {
    local out="$1"
    rm -f "${out}"
    "${BTTCLI}" export_preset name="${PRESET_NAME}" "outputPath=${out}" \
        includeSettings=true compress=false >/dev/null 2>&1 || true
    local i
    for i in $(seq 1 20); do
        [ -s "${out}" ] && return 0
        sleep 1
    done
    return 1
}

# Parsed rather than grepped: a grep for the raw JSON text depends on BTT's
# exact spacing ("name" : "x" vs "name": "x"), and if that ever changed every
# trigger would read as missing and the guard below would refuse every import.
btt_names() {
    btt_field "$1" BTTTriggerName
}

# Collect every value of one key anywhere in the preset, sorted and de-duped.
# Terminal commands are the part most likely to be stale on a machine that has
# not imported in a while, and they are what the verification below checks.
btt_field() {
    python3 - "$1" "$2" <<'PY' 2>/dev/null || true
import json, sys

def walk(node, key, out):
    if isinstance(node, dict):
        val = node.get(key)
        if isinstance(val, str) and val.strip():
            out.add(val)
        for v in node.values():
            walk(v, key, out)
    elif isinstance(node, list):
        for v in node:
            walk(v, key, out)

try:
    with open(sys.argv[1], encoding="utf-8") as fh:
        data = json.load(fh)
except Exception:
    sys.exit(0)

found = set()
walk(data, sys.argv[2], found)
for c in sorted(found):
    print(c)
PY
}

btt_commands() {
    btt_field "$1" BTTTerminalCommand
}

BACKUP="${DOTFILES_DIR}/bettertouchtool/.btt-backup-before-import.bttpreset"
LIVE="${TMPDIR_BTT}/live.bttpreset"

if btt_export "${LIVE}"; then
    cp "${LIVE}" "${BACKUP}"
    echo "   [backup] current BTT state -> bettertouchtool/$(basename "${BACKUP}")"
else
    LIVE=""
    if [ "${FORCE}" -ne 1 ]; then
        echo "   [warn] Could not read BTT's current state, so there is no backup and"
        echo "          no way to tell what an import would overwrite. Re-run with"
        echo "          --force to import anyway."
        exit 1
    fi
    echo "   [warn] Could not read BTT's current state — importing anyway (--force)."
fi

# ------------------------------------------------------------
# Refuse an import that would silently drop triggers.
# ------------------------------------------------------------
# The mirror of the guard in sync.sh. A preset is one blob: importing a file
# that is missing triggers deletes them, and on the machine holding
# btt-authority those deletions are then exported back to the repo and become
# permanent. Losing them is much more expensive than a refused import.
if [ -n "${LIVE}" ]; then
    LOST="$(comm -23 <(btt_names "${LIVE}") <(btt_names "${BTT_PRESET}") || true)"
    if [ -n "${LOST}" ]; then
        if [ "${FORCE}" -ne 1 ]; then
            echo "   [skip] This import would DROP triggers BTT currently has:"
            printf '%s\n' "${LOST}" | sed 's/^/            - /'
            echo "          These exist in BTT but not in the repo preset. Export them first"
            echo "          (scripts/sync.sh on the authority machine), or pass --force if"
            echo "          you really meant to delete them."
            exit 1
        fi
        echo "   [warn] --force: dropping triggers BTT currently has:"
        printf '%s\n' "${LOST}" | sed 's/^/            - /'
    fi
fi

# ------------------------------------------------------------
# Import.
# ------------------------------------------------------------
# A real import answers with the imported preset's name and uuid. "done", an
# empty line and exit 0 all mean the GUI sheet went unanswered and timed out.
# The uuid is the only trustworthy signal, and even it is only a hint — the
# verification below is what actually decides.
IMPORT_OUT="$("${BTTCLI}" import_preset path="${BTT_PRESET}" 2>&1 || true)"

case "${IMPORT_OUT}" in
    *uuid*) : ;;
    *)
        echo "   [warn] bttcli did not confirm the import."
        echo "          It answered: ${IMPORT_OUT:-<nothing>}"
        echo "          BTT raises a confirmation sheet for imports and gives it 30s."
        echo "          Bring BTT to the front, approve it (tick \"do not ask again\")"
        echo "          and re-run. Checking BTT's state anyway..."
        ;;
esac

# BTT reloads its whole configuration after an import and will not answer for a
# few seconds. Give it time before reading anything back.
sleep 3

# ------------------------------------------------------------
# Verify: prove the commands in the repo preset are the ones BTT now holds.
# ------------------------------------------------------------
# Preferred check is a fresh export, which is version-independent. If BTT is
# still busy reloading and will not export, fall back to reading the data store
# directly — less pretty, but it is the same state the shortcuts run from.
VERIFIED=""
AFTER="${TMPDIR_BTT}/after.bttpreset"

if btt_export "${AFTER}"; then
    # Compare decoded command strings on both sides. Grepping a decoded command
    # against the raw export never matches: the quotes inside every one of these
    # commands are escaped as \" in the JSON, so the two spellings differ even
    # when the commands are identical.
    MISSING="$(comm -23 \
        <(btt_commands "${BTT_PRESET}" | sort -u) \
        <(btt_commands "${AFTER}" | sort -u) | grep -c . || true)"
    if [ "${MISSING}" -eq 0 ]; then
        VERIFIED="yes"
    else
        echo "   [FAIL] ${MISSING} terminal command(s) from the repo preset are not in BTT."
    fi
else
    # Data store filename carries a BTT version and build, so glob for it rather
    # than pinning a name that changes under you on the next BTT update.
    STORE="$(ls -t "${BTT_SUPPORT}"/btt_data_store.version_* 2>/dev/null | grep -v -- '-wal$\|-shm$' | head -1)"
    if [ -n "${STORE}" ]; then
        MISSING=0
        while IFS= read -r cmd; do
            [ -z "${cmd}" ] && continue
            # The live value may sit in the write-ahead log rather than the main
            # database file, so both have to be searched before calling it absent.
            if ! { strings "${STORE}" "${STORE}-wal" 2>/dev/null | grep -Fq -- "${cmd}"; }; then
                MISSING=$((MISSING + 1))
            fi
        done <<EOF
$(btt_commands "${BTT_PRESET}")
EOF
        [ "${MISSING}" -eq 0 ] && VERIFIED="store"
    fi
fi

if [ "${VERIFIED}" = "yes" ]; then
    echo "   ✓ imported and verified against a fresh BTT export."
elif [ "${VERIFIED}" = "store" ]; then
    echo "   ✓ imported and verified against BTT's data store."
else
    echo "   [FAIL] Could not confirm the preset was imported."
    echo "          BTT's current state is backed up at:"
    echo "            ${BACKUP}"
    echo "          Import by hand instead: BTT -> Preset menu -> Import, and pick"
    echo "            ${BTT_PRESET}"
    exit 1
fi
