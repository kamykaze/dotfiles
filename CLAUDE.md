# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for configuring macOS development environment. It contains configuration files for various tools including Vim, shell environments, keyboard customization, and window management.

## Key Architecture

### File Naming Convention
- Files prefixed with `_` are symlinked to `$HOME` with the prefix replaced by `.`
- Example: `_bashrc` becomes `~/.bashrc`

### Installation System
- `install.sh` creates symlinks for all `_*` files and initializes git submodules
- Automatically runs `utilities/scripts/setup-vscode.sh` to symlink VS Code configs
- Run `./install.sh` to install all configurations

## Essential Configuration Files

### Keyboard Customization
- `_configs/kanata.kbd` - Kanata keyboard layout configuration with:
  - Home row modifiers (ASDF/JKL;)
  - Layer switching (numbers, navigation, mirror)
  - Custom key mappings and shortcuts
- `qmk_mappings/` - QMK keyboard firmware layouts for physical keyboards

### Window Management
- `_config/aerospace/aerospace.toml` - AeroSpace window manager configuration with:
  - Named workspaces (Main, Comm, Desktop, Media, etc.)
  - Multi-monitor support
  - Application-specific workspace assignments
- `bettertouchtool/` - BetterTouchTool presets and configurations for trackpad, touchbar, keyboard shortcuts

### Development Environment
- `_vimrc` - Full Vim configuration with extensive plugin setup
- `_vimrc_bare` - Minimal Vim configuration without plugins
- `_gvimrc` - GUI Vim specific configuration
- `_vim/` - Vim plugin directory using Pathogen for plugin management
- `_zshrc` - Zsh shell configuration (primary shell)
- `_tmux.conf` - Terminal multiplexer configuration
- `_gitconfig`, `_gitignore` - Git configuration and global ignore patterns
- `_inputrc` - Readline library configuration
- `_ackrc`, `_sackrc` - Code search tool configurations
- `_ignore` - Universal ignore patterns

### Additional Configurations
- `_configs/karabiner.json` - Karabiner-Elements configuration for keyboard customization
- `_configs/com.googlecode.iterm2.plist` - iTerm2 terminal emulator settings
- `_configs/vscode-settings.json` - Visual Studio Code settings
- `_configs/vscode-keybindings.json` - Visual Studio Code keybindings
- `_configs/vscode-extensions.txt` - List of installed VS Code extensions
- `_configs/itermcolors/` - Color schemes for iTerm2
- `chrome/` - Chrome browser extensions and configurations
- `_config/powerline/` - Powerline status line configuration

### Launch Daemons
- `utilities/launchdaemons/com.github.jtroo.kanata.plist` - Kanata launch daemon
- `utilities/scripts/` - Automation scripts and helper utilities
- `utilities/bin/` - Custom executable scripts

## Common Commands

### Installation
```bash
./install.sh  # Install all dotfiles via symlinks (includes VS Code setup)

# Manually install VS Code extensions (optional)
cat _configs/vscode-extensions.txt | xargs -L 1 code --install-extension
```

### Keyboard Layout Management
```bash
# Start Kanata (requires sudo for low-level keyboard access)
sudo kanata -c _configs/kanata.kbd
```

### Vim Plugin Management
The repository uses Pathogen for plugin management. All plugins are included as git submodules in `_vim/bundle/`.

## Development Notes

### Vim Configuration
- Extensive plugin ecosystem focused on web development (HTML/CSS/JS, Python/Django)
- Custom key mappings for faster navigation
- Home row window navigation (`<C-hjkl>`)
- Leader key is `,` for custom commands

### Keyboard Layout Features
- **Kanata configuration** includes:
  - Home row modifiers for ergonomic typing
  - Layer system for numbers, navigation, and symbols
  - Mirror layer for one-handed typing
  - Jump layer for quick layer switching

### Window Management
- AeroSpace provides i3-like tiling window management for macOS
- Named workspaces with automatic application assignment
- Multi-monitor workspace distribution

## File Structure

- `_*` files: Main configuration files (get symlinked to `~/.`)
- `_config/` and `_configs/`: Application-specific configurations
  - `_config/`: System-level configs (aerospace, powerline)
  - `_configs/`: User application configs (kanata, karabiner, iTerm2, VS Code)
- `utilities/`: Scripts, launch daemons, and helper tools
  - `bin/`: Custom executable scripts
  - `scripts/`: Automation and helper scripts
  - `launchdaemons/`: macOS launch daemon configurations
- `qmk_mappings/`: Physical keyboard firmware configurations for QMK keyboards
- `bettertouchtool/`: BetterTouchTool presets for trackpad, keyboard, and touchbar
- `assets/`: Documentation images and design files
- `karabiner_mods/`: Additional Karabiner-Elements modifications
- `chrome/`: Chrome browser extensions and settings
- `misc/`: Miscellaneous files and resources
- `deprecated/`: Archived configuration files no longer in use (bash configs, Atom editor, KMonad)
