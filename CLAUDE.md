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
- `scripts/karabiner-driver.sh` — pins the Karabiner virtual HID driver to the exact
  version kanata requires. Never move this to a Brewfile cask: `karabiner-elements`
  is `auto_updates` and will ship a driver kanata can't talk to, which silently
  breaks every mapping
- `scripts/launchagents.sh` — installs launchd services (eg: Kanata auto-start)
- `scripts/keymap-diagram.sh` — redraws `assets/keyboard-layers.svg` (embedded in the
  README) from `_configs/kanata.kbd`. Not part of `install.sh`. It relabels every raw
  chord using the BetterTouchTool preset, because kanata only knows it fires Meh+1
  and BTT is what knows Meh+1 means Obsidian. keymap-drawer's kanata parser is
  experimental upstream, so the version is pinned in the script

**Whenever `_configs/kanata.kbd` or the BetterTouchTool preset changes, run
`scripts/keymap-diagram.sh` and commit the redrawn SVG in the same commit.**
Nothing regenerates it automatically, and a keyboard map that lies is worse than
no map. Three things feed the drawing:
- chords the BTT preset binds are named from it (`Meh+a` → "Spotify")
- chords it doesn't bind are drawn plainly (`hyper+1`), which is a live list of
  mappings that fire into nothing
- anything whose intent isn't obvious from the chord gets a `;; :label <chord> =
  <text>` comment in `kanata.kbd` (eg: `lalt+left` → "prev word"). That comment is
  the only record of the mapping's purpose, so add one rather than leaving a bare
  chord on the diagram
- shortcuts in a BTT group whose name contains "window" are drawn as icons
  generated from the label's geometry ("Left Two Thirds" → a screen with its left
  two-thirds shaded). No icon set carries thirds vs quarters vs two-thirds, which
  is why these are generated rather than borrowed
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
- `scripts/keymap-mbp.json` - MacBook Pro physical key positions used to draw the
  layer map. `fn` and `touchid` are synthetic entries: macOS never sends them, so
  kanata cannot see them, but `fn` is held for voice dictation and belongs on the map
- `qmk_mappings/` - QMK keyboard firmware layouts for physical keyboards

### Window Management

- `bettertouchtool/` - BetterTouchTool presets and configurations for trackpad, touchbar, keyboard shortcuts

### Development Environment
- `_vimrc` - Full Vim configuration with extensive plugin setup
- `_vimrc_bare` - Minimal Vim configuration without plugins
- `_vim/` - Vim plugin directory using Pathogen for plugin management
- `_zshrc` - Zsh shell configuration (primary shell)
- `_gitconfig`, `_gitignore` - Git configuration and global ignore patterns
- `_inputrc` - Readline library configuration
- `_ignore` - Universal ignore patterns

### Additional Configurations
- `_configs/vscode-settings.json` - VS Code settings **snapshot** (never symlinked — Settings Sync owns the live file)
- `_configs/vscode-keybindings.json` - VS Code keybindings **snapshot** (same rule)
- `_configs/vscode-extensions.txt` - Snapshot of installed VS Code extensions, dumped by `scripts/sync.sh`.
  Not an install list — the Brewfile's `vscode "..."` entries do the installing.
- `chrome/` - Chrome browser extensions and configurations

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
./install.sh  # Install all dotfiles via symlinks

# VS Code needs nothing extra: extensions come from the Brewfile's `vscode` entries,
# settings/keybindings from Settings Sync. Do NOT symlink vscode-*.json into
# ~/Library/Application Support/Code/User/ — it breaks Settings Sync.
```

### Keyboard Layout Management
```bash
# Start Kanata (requires sudo for low-level keyboard access)
sudo kanata -c _configs/kanata.kbd
```

### Vim Plugin Management
The repository uses Pathogen for plugin management. All plugins are included as git submodules in `_vim/bundle/`.

---

## Where Work Gets Tracked

There is deliberately **no TODO file and no GitHub issues** in this repo.
Outstanding work lives in ClickUp (Kam Space -> Productivity list), because
that is what generates Kam's day — a task filed anywhere else never surfaces
in planning and rots. `TODO.txt` proved this: it sat unlinked and untouched
from April to September 2026 while every item in it went stale.

What *does* belong here is the **reasoning** — why a thing is built the way it
is. Commit messages carry most of it; this file and `deprecated/README.md`
carry the rest. Decisions in the repo, intentions in ClickUp.

Issues stay enabled on the public repo as a reception desk for other people,
not as a personal backlog.

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
| Kanata | `_configs/kanata.kbd` symlinked to `~/.configs/kanata.kbd`. Private aliases in
gitignored `_configs/kanata-private.kbd` (template committed). Virtual HID driver version
is pinned by `scripts/karabiner-driver.sh`, NOT by a Brewfile cask |
| BetterTouchTool | `.bttpreset` export in `bettertouchtool/` |
| Claude Desktop | Nothing in the repo — sign in and the hosted connectors follow the account. Its `claude_desktop_config.json` is app-owned; never copy a repo version over it |
| Claude Code (global) | `claude/CLAUDE.md` symlinked to `~/.claude/CLAUDE.md` (handled in `scripts/symlinks.sh`) |
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

## Searching the Repo

- **Scope Glob/Grep searches.** Exclude `_vim/bundle/` (Vim plugin submodules — dozens of vendored repos) and `deprecated/` to avoid noise. Prefer `path` parameters or specific patterns over searching the repo root blindly.
- Reading a specific file with Read has no such restriction — any file may be needed for troubleshooting.

---

## File Structure

- `_*` files: Main configuration files (get symlinked to `~/.`)
- `_config/` and `_configs/`: Application-specific configurations
  - `_configs/`: User application configs (kanata, VS Code)
- `claude/`: Global Claude Code instructions — `CLAUDE.md` symlinked to `~/.claude/CLAUDE.md`
- `scripts/`: Bootstrap scripts called by `install.sh`
- `utilities/`: Scripts, launch daemons, and helper tools
  - `bin/`: Custom executable scripts (eg: `lidguard` — lid-close "travel mode" with thermal-pressure/battery safety cutoffs; symlinked to `~/.local/bin/`)
  - `scripts/`: Automation and helper scripts
  - `launchdaemons/`: macOS launch daemon configurations
- `qmk_mappings/`: Physical keyboard firmware configurations for QMK keyboards
- `bettertouchtool/`: BetterTouchTool presets for trackpad, keyboard, and touchbar
- `assets/`: Documentation images and design files
- `chrome/`: Chrome browser extensions and settings
- `misc/`: Miscellaneous files and resources
- `deprecated/`: Archived configuration files no longer in use (bash configs, Atom editor, KMonad)
