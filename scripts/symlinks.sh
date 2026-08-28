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

# lidguard travel-mode CLI: utilities/bin/lidguard -> ~/.local/bin/lidguard
# (~/.local/bin is already on PATH; symlinked so repo edits take effect live.)
if [ -f "${DOTFILES_DIR}/utilities/bin/lidguard" ]; then
    echo "-> Symlinking lidguard CLI..."
    mkdir -p "${HOME}/.local/bin"
    if [ -L "${HOME}/.local/bin/lidguard" ]; then
        echo "  [skip] ~/.local/bin/lidguard (already linked)"
    elif [ -e "${HOME}/.local/bin/lidguard" ]; then
        echo "  [skip] ~/.local/bin/lidguard (exists as non-symlink, skipping)"
    else
        ln -s "${DOTFILES_DIR}/utilities/bin/lidguard" "${HOME}/.local/bin/lidguard"
        echo "  [link] utilities/bin/lidguard -> ~/.local/bin/lidguard"
    fi
fi

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
