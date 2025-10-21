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

## Note

These files are kept for reference only and are **not** symlinked by `install.sh`.
