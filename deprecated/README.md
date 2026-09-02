# Deprecated Configuration Files

This directory contains configuration files that are no longer actively used but are preserved for historical reference.

## Files

### Bash Configuration (Archived Oct 2025)
- `_bashrc` - Legacy Bash shell configuration
- `_bash_profile` - Legacy Bash profile configuration

**Reason for archival:** Switched to zsh as primary shell. These files contain outdated configurations including:
- Python 2.7 references
- Legacy pythonbrew and virtualenvwrapper paths
- Old powerline configuration
- Deprecated tool paths

Most useful functionality (aliases, functions) has been migrated to `_zshrc`.

### Atom Editor Configuration (Archived Oct 2025)
- `_atom/` - Atom editor configuration files (init.coffee, keymap.cson, snippets.cson, styles.less)

**Reason for archival:** Atom editor was discontinued by GitHub in December 2022. Migrated to VS Code as primary editor.

### KMonad Keyboard Configuration (Archived Oct 2025)
- `_kmonad.kbd` - KMonad keyboard remapping configuration (225 lines)

**Reason for archival:** Migrated to Kanata for keyboard remapping. Kanata is more powerful, actively maintained, and better suited for complex keyboard layouts with multi-layer support.

### Powerline (Archived Sep 2026)
- `powerline/` - prompt theming: instructions, screenshot, `_config/powerline/`
  config, and the custom vim segment from `utilities/powerline_custom/`

**Reason for archival:** Warp is the terminal now and draws its own prompt, so
shell prompt theming via powerline has no job. The `utilities/powerline`
submodule was removed outright rather than archived. Note that `_vimrc` still
sets `g:airline_powerline_fonts` — that is vim-airline asking for powerline
*glyphs*, unrelated to this package, and it still works.

### Tmux (Archived Sep 2026)
- `tmux/_tmux.conf`, `tmux/tmuxinator.bash`, `tmux/tmuxinator.zsh`

**Reason for archival:** Warp handles panes and splits. The
`utilities/tmux-MacOSX-pasteboard` submodule was removed outright. `_vimrc`
still carries `<Leader>m` / `<Leader>z` tmux-send mappings (lines ~1042-1046);
they are inert without tmux but harmless, and were left alone.

### Chrome DevTools Themes (Archived Sep 2026)
- `chrome-devtools-themes/devthemes_fix/` - a DevTools theme loader extension

**Reason for archival:** Chrome removed the custom-stylesheet hook this relied
on years ago, so it no longer functions. The `Readable-ChromeDevThemes`
submodule was removed outright, along with a stale `.gitmodules` entry for
`chrome/chrome-devtools-theme` whose path never existed in the tree.

**Not affected:** `utilities/scripts/chrome-tab-focus.sh` is unrelated and still
live — BetterTouchTool shortcuts call it.

### BetterTouchTool JSON exports (Archived Sep 2026)
- `bettertouchtool-json/` - `base`, `bttremote`, `keyboard`, `magicmouse`,
  `other`, `touchbar`, `trackpad`

**Reason for archival:** Superseded by `bettertouchtool/kam_btt_presets.bttpreset`,
which `scripts/sync.sh` exports via `bttcli` and `install.sh` imports. These
per-domain JSON files were a manual export format that nothing reads any more.

## Note

These files are kept for reference only and are **not** symlinked by `install.sh`.
