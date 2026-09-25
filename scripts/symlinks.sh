#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Targets that already exist as real files. We never overwrite them, but a lone
# `[skip]` line scrolls past in a wall of `[link]` output — ~/.gitconfig sat
# unlinked for two days that way, so every alias in _gitconfig was inert.
# Collected here and reported loudly at the end.
BLOCKED=""

link_file() {
    local source="${DOTFILES_DIR}/$1"
    local target="${HOME}/${1/_/.}"

    if [ -L "${target}" ]; then
        echo "  [skip] ${target} (already linked)"
    elif [ -e "${target}" ]; then
        echo "  [skip] ${target} (exists as non-symlink, skipping)"
        BLOCKED="${BLOCKED}${target}\n"
    else
        ln -s "${source}" "${target}"
        echo "  [link] ${source} -> ${target}"
    fi
}

echo "-> Symlinking dotfiles..."

# Link all top-level _* files and directories
# Exceptions handled separately: _ssh_config, _config (see below)
for item in "${DOTFILES_DIR}"/_*; do
    name="$(basename "${item}")"
    if [ "${name}" = "_ssh_config" ] || [ "${name}" = "_config" ]; then
        continue
    fi
    link_file "${name}"
done

# _config/ subdirectories -> ~/.config/<name>/
# Can't symlink _config -> ~/.config wholesale because ~/.config already exists.
# The directory is absent whenever nothing needs ~/.config; without this guard
# the glob below expands to the literal "_config/*/" and links a dir named "*".
if [ -d "${DOTFILES_DIR}/_config" ]; then
echo "-> Symlinking ~/.config/ subdirectories..."
mkdir -p "${HOME}/.config"
for subdir in "${DOTFILES_DIR}/_config"/*/; do
    name="$(basename "${subdir}")"
    target="${HOME}/.config/${name}"
    if [ -L "${target}" ]; then
        echo "  [skip] ~/.config/${name} (already linked)"
    elif [ -e "${target}" ]; then
        echo "  [skip] ~/.config/${name} (exists as non-symlink, skipping)"
    else
        ln -s "${subdir%/}" "${target}"
        echo "  [link] _config/${name} -> ~/.config/${name}"
    fi
done
fi

# SSH config: _ssh_config -> ~/.ssh/config
if [ -f "${DOTFILES_DIR}/_ssh_config" ]; then
    echo "-> Symlinking SSH config..."
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"
    if [ -L "${HOME}/.ssh/config" ]; then
        echo "  [skip] ~/.ssh/config (already linked)"
    elif [ -e "${HOME}/.ssh/config" ]; then
        echo "  [skip] ~/.ssh/config (exists as non-symlink, skipping)"
        BLOCKED="${BLOCKED}${HOME}/.ssh/config\n"
    else
        ln -s "${DOTFILES_DIR}/_ssh_config" "${HOME}/.ssh/config"
        echo "  [link] _ssh_config -> ~/.ssh/config"
    fi

    # _ssh_config routes github.com over ssh.github.com:443 (works on networks
    # that block 22). That host is NOT in a fresh known_hosts, so every git
    # operation dies with "Host key verification failed" until it is added.
    # Take the keys from GitHub's published list over TLS rather than
    # ssh-keyscan, so there is no trust-on-first-use step.
    if grep -q "ssh.github.com" "${DOTFILES_DIR}/_ssh_config" 2>/dev/null \
       && ! grep -q "\[ssh.github.com\]:443" "${HOME}/.ssh/known_hosts" 2>/dev/null; then
        echo "  Seeding known_hosts for ssh.github.com:443..."
        if KEYS="$(curl -fsS --max-time 15 https://api.github.com/meta \
                   | python3 -c 'import json,sys; [print(f"[ssh.github.com]:443 {k}") for k in json.load(sys.stdin)["ssh_keys"]]' 2>/dev/null)" \
           && [ -n "${KEYS}" ]; then
            printf '%s\n' "${KEYS}" >> "${HOME}/.ssh/known_hosts"
            chmod 600 "${HOME}/.ssh/known_hosts"
            echo "  [ok] added GitHub host keys for port 443"
        else
            echo "  [warn] could not fetch GitHub host keys — git over SSH may fail with"
            echo "         'Host key verification failed'. Re-run this script when online."
        fi
    fi
fi

# Claude global instructions: claude/CLAUDE.md -> ~/.claude/CLAUDE.md
# ~/.claude holds session/memory data we don't track, so link just this one file.
if [ -f "${DOTFILES_DIR}/claude/CLAUDE.md" ]; then
    echo "-> Symlinking Claude global instructions..."
    mkdir -p "${HOME}/.claude"
    if [ -L "${HOME}/.claude/CLAUDE.md" ]; then
        echo "  [skip] ~/.claude/CLAUDE.md (already linked)"
    elif [ -e "${HOME}/.claude/CLAUDE.md" ]; then
        echo "  [skip] ~/.claude/CLAUDE.md (exists as non-symlink, skipping)"
    else
        ln -s "${DOTFILES_DIR}/claude/CLAUDE.md" "${HOME}/.claude/CLAUDE.md"
        echo "  [link] claude/CLAUDE.md -> ~/.claude/CLAUDE.md"
    fi
fi

# Claude settings: claude/settings.json -> ~/.claude/settings.json
# Holds the permission allowlist, which is load-bearing for the unattended
# vault-drain agent: ClickUp filter/get/tag/update only (never delete), and every
# vault folder EXCEPT 90 - Private/. Untracked, that grant lives on one machine and
# a rebuild either breaks the drain or re-grants broadly without knowing why it was
# narrow.
#
# Unlike CLAUDE.md, Claude Code WRITES this file when a permission is approved. If it
# ever replaces rather than edits in place, the symlink becomes a real file and the
# repo silently stops tracking it. So this block repairs rather than skips: identical
# content is re-linked, divergent content is reported instead of being clobbered.
if [ -f "${DOTFILES_DIR}/claude/settings.json" ]; then
    echo "-> Symlinking Claude settings..."
    mkdir -p "${HOME}/.claude"
    if [ -L "${HOME}/.claude/settings.json" ]; then
        echo "  [skip] ~/.claude/settings.json (already linked)"
    elif [ -e "${HOME}/.claude/settings.json" ]; then
        if diff -q "${HOME}/.claude/settings.json" "${DOTFILES_DIR}/claude/settings.json" >/dev/null 2>&1; then
            rm "${HOME}/.claude/settings.json"
            ln -s "${DOTFILES_DIR}/claude/settings.json" "${HOME}/.claude/settings.json"
            echo "  [relink] ~/.claude/settings.json was a real file, identical - re-linked"
        else
            echo "  [WARN] ~/.claude/settings.json exists and DIFFERS from the repo copy."
            echo "         Not overwriting. Diff them, merge by hand, then re-run:"
            echo "           diff ~/.claude/settings.json ${DOTFILES_DIR}/claude/settings.json"
        fi
    else
        ln -s "${DOTFILES_DIR}/claude/settings.json" "${HOME}/.claude/settings.json"
        echo "  [link] claude/settings.json -> ~/.claude/settings.json"
    fi
fi

# Repo scripts that outside callers invoke by absolute path get a stable home in
# ~/.local/bin, so nothing has to encode where this repo is checked out.
# (~/.local/bin is already on PATH; symlinked so repo edits take effect live.)
#
# This is not just tidiness for chrome-tab-focus: BetterTouchTool round-trips its
# whole preset on every sync (scripts/sync.sh exports it from the authority
# machine and commits the result), so a repo path written into a BTT command is
# re-expanded and written back on the next export. A placeholder cannot survive
# that. A symlink can, because BTT never learns the real path at all.
link_bin() {
    local source="${DOTFILES_DIR}/$1"
    local name="$2"
    local target="${HOME}/.local/bin/${name}"

    [ -f "${source}" ] || return 0
    mkdir -p "${HOME}/.local/bin"
    if [ -L "${target}" ]; then
        echo "  [skip] ~/.local/bin/${name} (already linked)"
    elif [ -e "${target}" ]; then
        echo "  [skip] ~/.local/bin/${name} (exists as non-symlink, skipping)"
    else
        ln -s "${source}" "${target}"
        echo "  [link] $1 -> ~/.local/bin/${name}"
    fi
}

echo "-> Symlinking repo scripts into ~/.local/bin..."
link_bin "utilities/bin/lidguard" "lidguard"
link_bin "utilities/scripts/chrome-tab-focus.sh" "chrome-tab-focus"

if [ -n "${BLOCKED}" ]; then
    echo ""
    echo "  =================================================================="
    echo "  NOT LINKED — these exist as real files, so the repo version is"
    echo "  INACTIVE. Nothing was overwritten. Merge and replace them by hand:"
    printf "${BLOCKED}" | sed '/^$/d; s|^|      |'
    echo ""
    echo "  For each: move machine-specific values into a local override file,"
    echo "  then delete the real file and re-run this script."
    echo "  =================================================================="
fi

echo "   Done."
