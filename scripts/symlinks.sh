#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

link_file() {
    local source="${DOTFILES_DIR}/$1"
    local target="${HOME}/${1/_/.}"

    if [ -L "${target}" ]; then
        echo "  [skip] ${target} (already linked)"
    elif [ -e "${target}" ]; then
        echo "  [skip] ${target} (exists as non-symlink, skipping)"
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
        echo "  [skip] ~/.ssh/config (exists, skipping)"
    else
        ln -s "${DOTFILES_DIR}/_ssh_config" "${HOME}/.ssh/config"
        echo "  [link] _ssh_config -> ~/.ssh/config"
    fi
fi

echo "   Done."
