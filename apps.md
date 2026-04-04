# Apps

A categorized inventory of all apps on this machine.

---

## (a) Homebrew-managed (Brewfile)

All of these are installed automatically by `scripts/homebrew.sh` via `Brewfile`.

### CLI Tools
| App | Formula |
|-----|---------|
| coreutils | `brew install coreutils` |
| fzf | `brew install fzf` |
| GitHub CLI | `brew install gh` |
| just | `brew install just` |
| Node.js | `brew install node` |
| Python 3.12 | `brew install python@3.12` |
| Kanata | `brew install kanata` |
| FFmpeg | `brew install ffmpeg` |
| Go | `brew install go` |
| ImageMagick | `brew install imagemagick` |
| MySQL | `brew install mysql` |
| Stripe CLI | `brew install stripe/stripe-cli/stripe` |
| Heroku CLI | `brew install heroku/brew/heroku` |

### GUI Apps (Casks)
| App | Cask | Notes |
|-----|------|-------|
| BetterTouchTool | `bettertouchtool` | Trackpad/keyboard customization — needs license key (LastPass) |
| Claude Desktop | `claude` | AI assistant — needs MCP config (see SETUP_NOTES.md) |
| Google Drive | `google-drive` | Cloud storage |
| Granola | `granola` | AI meeting notes |
| Jumpcut | `jumpcut` | Clipboard manager |
| Warp | `warp` | Terminal — has cloud sync |

### VS Code Extensions
Managed via Brewfile vscode entries — installed automatically by `brew bundle`.
See `_configs/vscode-extensions.txt` for the full list.

---

## (b) Manual Installs

These apps are not available via Homebrew and require a direct download.

| App | Download | Notes |
|-----|----------|-------|
| Whispr Flow | https://www.whisprflow.ai | Voice dictation — change trigger key after install (see SETUP_NOTES.md) |
| Brain.fm | https://www.brain.fm | Focus music — web or App Store |
| iTerm2 | https://iterm2.com | Terminal alternative — config in `_configs/com.googlecode.iterm2.plist` |

---

## (c) App Store Apps

These apps must be installed manually from the Mac App Store and cannot be scripted.

| App | Notes |
|-----|-------|
| Brain.fm | Focus music (also available as web app) |
| Any other App Store exclusives | Check your purchase history |

---

## Notes

- Run `brew bundle --file=Brewfile` to install all Homebrew-managed apps on a new machine.
- For App Store purchases, sign in to the App Store with your Apple ID first.
- License keys (BetterTouchTool, etc.) are stored in **LastPass**.
