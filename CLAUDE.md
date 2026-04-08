# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for configuring macOS development environment. It contains configuration files for various tools including Vim, shell environments, keyboard customization, and window management.

The long-term goal is a **full bootstrap system** — clone repo, run `install.sh`, and have a new machine configured with minimal manual steps.

---

## Key Architecture

### File Naming Convention
- Files prefixed with `_` are symlinked to `$HOME` with the prefix replaced by `.`
- Example: `_bashrc` becomes `~/.bashrc`
- `_configs/` is symlinked to `~/.configs/`
- Non-home paths (eg: `~/Library/...`) are handled explicitly in `scripts/`

### Installation System
- `install.sh` is the main entry point — it delegates to scripts in `scripts/`
- `scripts/symlinks.sh` — handles all symlinking (`_*` files and `_configs/`)
- `scripts/homebrew.sh` — installs Homebrew and runs Brewfile
- `scripts/macos.sh` — applies system preferences via `defaults write`
- `scripts/launchagents.sh` — installs launchd services (eg: Kanata auto-start)
- Run `./install.sh` to install all configurations

### Script Conventions
- Every script uses `set -e` at the top (stop on first error)
- Every script is **idempotent** — safe to run multiple times without breaking anything
- Every step prints clear output: `echo "-> doing thing..."` and `echo "✓ done"`
- Never put logic directly in `install.sh` — it delegates to `scripts/`

---

## Essential Configuration Files

### Keyboard Customization
- `_configs/kanata.kbd` - Kanata keyboard layout configuration with:
  - Home row modifiers (ASDF/JKL;)
  - Layer switching (numbers, navigation, symbols, shortcuts, mirror, plain, disabled)
  - Custom key mappings and shortcuts
- `qmk_mappings/` - QMK keyboard firmware layouts for physical keyboards

### Window Management

- `bettertouchtool/` - BetterTouchTool presets and configurations for trackpad, touchbar, keyboard shortcuts

### Development Environment
- `_vimrc` - Full Vim configuration with extensive plugin setup
- `_vimrc_bare` - Minimal Vim configuration without plugins
- `_vim/` - Vim plugin directory using Pathogen for plugin management
- `_zshrc` - Zsh shell configuration (primary shell)
- `_tmux.conf` - Terminal multiplexer configuration
- `_gitconfig`, `_gitignore` - Git configuration and global ignore patterns
- `_inputrc` - Readline library configuration
- `_ignore` - Universal ignore patterns

### Additional Configurations
- `_configs/vscode-settings.json` - Visual Studio Code settings
- `_configs/vscode-keybindings.json` - Visual Studio Code keybindings
- `_configs/vscode-extensions.txt` - List of installed VS Code extensions
- `chrome/` - Chrome browser extensions and configurations
- `_config/powerline/` - Powerline status line configuration

### Sensitive Config Templates
- `_configs/*.template` files contain configs with sensitive data redacted
- Placeholders look like: `"token": "YOUR_API_KEY"  // stored in LastPass: <note name>`
- **Never commit the real config file** — only the `.template` version
- Real values are stored in **LastPass**

### Launch Daemons
- `utilities/launchdaemons/com.github.jtroo.kanata.plist` - Kanata launch daemon
- `utilities/scripts/` - Automation scripts and helper utilities
- `utilities/bin/` - Custom executable scripts

---

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

---

## Sensitive Data Rules

These are non-negotiable. Follow them for every file touched in this repo.

- **Nothing sensitive ever goes in this repo** — not even in a private repo
- API keys and tokens → use `.template` files with placeholder comments
- SSH private keys → LastPass only, never the repo
- Only `~/.ssh/config` (host aliases) goes in the repo, never key files
- `.gitignore` must block: `.env`, `*.pem`, `*_rsa`, `*.key`, `id_ed25519`,
  and any real config file that has a `.template` counterpart
- Sensitive data is stored in: **LastPass**

---

## Key Apps and Config Strategy

| App | Config approach |
|-----|----------------|
| Kanata | `_configs/kanata.kbd` symlinked to `~/.configs/kanata.kbd` |
| BetterTouchTool | `.bttpreset` export in `bettertouchtool/` |
| Claude Desktop | `.template` file in `_configs/`, real keys in LastPass |
| VS Code | Built-in Settings Sync (GitHub account) — nothing extra needed |
| Warp | Cloud sync via Warp account — local themes/configs in `_configs/` if needed |
| SSH | `_ssh_config` symlinked to `~/.ssh/config` — private keys in LastPass |
| Chrome Tabs | Focused via `utilities/scripts/chrome-tab-focus.sh`, triggered by BetterTouchTool shortcuts |

---

## Adding New Configs

When you add a new app or tool to your setup:

1. If installable via Homebrew Cask → add to `Brewfile`
2. If manual install → add to `apps.md` with download link
3. If it has config files → add to `_configs/` and update `scripts/symlinks.sh`
4. If it has post-install steps → add to `SETUP_NOTES.md`
5. If config has sensitive data → use a `.template` file, store real values in LastPass

---

## Development Notes

### Vim Configuration
- Extensive plugin ecosystem focused on web development (HTML/CSS/JS, Python/Django)
- Custom key mappings for faster navigation
- Home row window navigation (`<C-hjkl>`)
- Leader key is `,` for custom commands

### Keyboard Layout Features
- **Kanata configuration** includes:
  - Home row modifiers for ergonomic typing
  - Layer system for numbers, navigation, symbols, and shortcuts
  - Mirror layer for one-handed typing
  - Jump layer for quick layer switching
  - Plain layer for gaming or standard typing
  - Disabled layer for securing keyboard when not in use

---

## File Structure

- `_*` files: Main configuration files (get symlinked to `~/.`)
- `_config/` and `_configs/`: Application-specific configurations
  - `_config/`: System-level configs (powerline)
  - `_configs/`: User application configs (kanata, VS Code)
- `scripts/`: Bootstrap scripts called by `install.sh`
- `utilities/`: Scripts, launch daemons, and helper tools
  - `bin/`: Custom executable scripts
  - `scripts/`: Automation and helper scripts
  - `launchdaemons/`: macOS launch daemon configurations
- `qmk_mappings/`: Physical keyboard firmware configurations for QMK keyboards
- `bettertouchtool/`: BetterTouchTool presets for trackpad, keyboard, and touchbar
- `assets/`: Documentation images and design files
- `chrome/`: Chrome browser extensions and settings
- `misc/`: Miscellaneous files and resources
- `deprecated/`: Archived configuration files no longer in use (bash configs, Atom editor, KMonad)
