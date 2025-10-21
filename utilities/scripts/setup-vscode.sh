#!/usr/bin/env bash
# Setup VS Code configuration symlinks

VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VSCODE_CONFIG_DIR="$DOTFILES_DIR/_configs"

echo "Setting up VS Code configuration..."

# Create VS Code User directory if it doesn't exist
mkdir -p "$VSCODE_USER_DIR"

# Backup and symlink settings.json
if [ -f "$VSCODE_USER_DIR/settings.json" ] && [ ! -L "$VSCODE_USER_DIR/settings.json" ]; then
    echo "Backing up existing settings.json..."
    mv "$VSCODE_USER_DIR/settings.json" "$VSCODE_USER_DIR/settings.json.backup.$(date +%Y%m%d)"
fi

if [ ! -L "$VSCODE_USER_DIR/settings.json" ]; then
    echo "Symlinking settings.json..."
    ln -sf "$VSCODE_CONFIG_DIR/vscode-settings.json" "$VSCODE_USER_DIR/settings.json"
fi

# Backup and symlink keybindings.json
if [ -f "$VSCODE_USER_DIR/keybindings.json" ] && [ ! -L "$VSCODE_USER_DIR/keybindings.json" ]; then
    echo "Backing up existing keybindings.json..."
    mv "$VSCODE_USER_DIR/keybindings.json" "$VSCODE_USER_DIR/keybindings.json.backup.$(date +%Y%m%d)"
fi

if [ ! -L "$VSCODE_USER_DIR/keybindings.json" ]; then
    echo "Symlinking keybindings.json..."
    ln -sf "$VSCODE_CONFIG_DIR/vscode-keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
fi

echo "VS Code configuration setup complete!"
echo ""
echo "To install extensions, run:"
echo "  cat $VSCODE_CONFIG_DIR/vscode-extensions.txt | xargs -L 1 code --install-extension"
