# dotfiles

Personal macOS development environment — clone and run `install.sh` to get a fully configured machine.

## Quick Start

```bash
git clone https://github.com/kamykaze/dotfiles.git ~/personal/projects/dotfiles
cd ~/personal/projects/dotfiles
./install.sh
```

`install.sh` will:

- Install Xcode Command Line Tools (if missing)
- Install Homebrew and all packages from `Brewfile`
- Create all dotfile symlinks (`_*` → `~/.`)
- Set up VS Code settings and extensions
- Wire up the Kanata keyboard LaunchAgent

After running `install.sh`, see [SETUP_NOTES.md](SETUP_NOTES.md) for manual steps (SSH keys, app licenses, first-time app setup).

---

## How It Works

### File Naming Convention

Files prefixed with `_` are symlinked into `$HOME` with the prefix replaced by `.`:

```text
_zshrc        →  ~/.zshrc
_gitconfig    →  ~/.gitconfig
_tmux.conf    →  ~/.tmux.conf
_configs/     →  ~/.configs/
```

### Scripts

| Script | Purpose |
| --- | --- |
| `install.sh` | Main entry point — delegates to all scripts below |
| `scripts/symlinks.sh` | Creates all dotfile symlinks |
| `scripts/homebrew.sh` | Installs Homebrew and runs Brewfile |
| `scripts/macos.sh` | Applies macOS system preferences via `defaults write` |
| `scripts/launchagents.sh` | Installs launchd services (Kanata auto-start) |
| `scripts/sync.sh` | Exports configs from apps that own their files (run daily via LaunchAgent) |

All scripts are idempotent — safe to run multiple times.

---

## Key Configurations

### Shell & Terminal

- `_zshrc` — Zsh configuration (primary shell)
- `_tmux.conf` — Tmux configuration

### Editor

- `_vimrc` — Full Vim config with Pathogen plugin management, focused on web development (HTML/CSS/JS, Python/Django)
- `_vimrc_bare` — Minimal Vim config without plugins
- `_vim/` — Vim plugins (git submodules via Pathogen)

### Git

- `_gitconfig` — Git aliases and settings
- `_gitignore` — Global ignore patterns

### Keyboard

- `_configs/kanata.kbd` — [Kanata](https://github.com/jtroo/kanata) keyboard remapping:
  - Home row modifiers (ASDF / JKL;)
  - Layers: numbers, navigation, symbols, shortcuts, mirror, plain, disabled
- `qmk_mappings/` — QMK firmware layouts for physical keyboards

### Applications

- `_configs/vscode-settings.json` / `vscode-keybindings.json` — VS Code settings (symlinked by install.sh)
- `_configs/vscode-extensions.txt` — VS Code extensions list
- `bettertouchtool/` — BetterTouchTool presets (trackpad, keyboard, touchbar)
- `utilities/scripts/chrome-tab-focus.sh` — Focuses Chrome tabs (Gmail, Docs, Sheets, etc.) by URL and title, called by BetterTouchTool shortcuts

### Sensitive Configs

Files with secrets are kept out of the repo. Instead:

- `_configs/*.template` files contain the structure with placeholders like `"token": "YOUR_API_KEY"`
- Real values are stored in **LastPass**
- See [SETUP_NOTES.md](SETUP_NOTES.md) for which LastPass notes to use

---

## Keeping Configs in Sync

Symlinked files (`~/.zshrc`, `~/.gitconfig`, etc.) are always in sync — editing them **is** editing the repo. Just `git commit` when ready.

For apps that own their config files (VS Code extensions, etc.), run:

```bash
./scripts/sync.sh   # copies latest app configs into the repo
git diff            # review changes
git add -p && git commit -m "chore: sync configs"
```

---

## Adding a New Config

See [SETUP_NOTES.md](SETUP_NOTES.md) for the full patterns. Quick summary:

- Config at `~/.*` → copy to `_*`, run `scripts/symlinks.sh`
- Config at `~/Library/...` → copy to `_configs/`, add to `sync.sh` and `symlinks.sh`
- Config at `~/.config/<app>/` → copy to `_config/<app>/`, run `scripts/symlinks.sh`
- New Homebrew app → add to `Brewfile`
- Manual-install app → add to `apps.md`
- Config with secrets → `.template` file only, real values in LastPass
