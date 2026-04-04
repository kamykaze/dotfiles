# Setup Notes

---

## Before running install.sh

Only two things are needed before you can run `install.sh` on a fresh machine.
`install.sh` itself has no dependency on SSH keys or GitHub credentials.

### Step 1 — Clone the repo (HTTPS, no SSH key needed)

```bash
# Clone via HTTPS — no SSH key required
git clone https://github.com/kamykaze/dotfiles.git ~/personal/projects/dotfiles
cd ~/personal/projects/dotfiles
```

You can clone to any path. The scripts use `$HOME` and relative paths throughout,
so the repo location is flexible.

### Step 2 — Run install.sh

```bash
./install.sh
```

This will: install Xcode CLT (if missing), install Homebrew and all packages from
the Brewfile, create all dotfile symlinks, set up VS Code, and wire up the Kanata
LaunchAgent.

### After install.sh — manual steps

The rest of this file covers things that can't be automated.

---

## 1. SSH Keys

SSH host aliases are in the repo (`_ssh_config` → `~/.ssh/config`), but the
private keys are NOT. Restore them from LastPass.

```bash
# After restoring keys from LastPass:
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
ssh-add ~/.ssh/id_ed25519
```

**LastPass note:** SSH Private Keys

---

## 2. Claude Desktop — MCP Configuration

The MCP server config contains API keys that aren't in the repo.

```bash
# Copy the template and fill in your API keys
cp ~/.configs/claude_desktop_config.json.template \
   ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Then edit the file and replace all YOUR_* placeholders
```

**LastPass note:** MCP API Keys

---

## 3. BetterTouchTool

1. Open BetterTouchTool
2. Go to **File → Import Preset** and select `bettertouchtool/*.bttpreset`
3. Enter your license key from LastPass

**LastPass note:** BetterTouchTool License

---

## 4. VS Code — Settings Sync

VS Code settings are in the repo (`_configs/vscode-settings.json`) and
symlinked by `install.sh`. However, you should also sign in to Settings Sync
on first launch to pull any additional state (keybindings, snippets, etc.)
that may have changed since the last export.

1. Open VS Code
2. Click the account icon (bottom left) → **Turn on Settings Sync**
3. Sign in with your **GitHub** account

---

## 5. Warp Terminal

Warp syncs themes, launch configs, and AI settings via cloud.

1. Open Warp
2. Sign in to your Warp account to restore cloud sync settings

---

## 6. Whispr Flow — Dictation Trigger Key

Whispr Flow defaults to the `fn` key for dictation. Change it to match the
Kanata shortcuts layer mapping.

1. Open **Whispr Flow → Settings → Hotkeys**
2. Change the trigger key to match your Kanata config

---

## 7. Kanata — First-time Setup

Kanata on macOS depends on the **Karabiner virtual HID driver** for keyboard output.
`karabiner-elements` is in the Brewfile and installs the driver, but you must
activate it manually on first launch.

**Step 1 — Activate the Karabiner driver:**

1. Open Karabiner-Elements (installed via Brewfile)
2. Follow the prompt to activate the DriverKit virtual HID device
3. Go to **System Settings → Privacy & Security** and approve the driver if prompted
4. You do not need to configure Karabiner itself — just the driver needs to be active

If you skip this, Kanata will fail with:
`failed to open keyboard device(s): Karabiner-VirtualHIDDevice driver is not activated`

**Step 2 — Grant Accessibility permission:**

1. Open **System Settings → Privacy & Security → Accessibility**
2. Add `kanata` (or `~/bin/kanata-runner.sh`) to the allowed list

The LaunchAgent is installed by `scripts/launchagents.sh`. If Kanata silently
fails to run after reboot, one of the above two permissions is usually the cause.

---

## 8. Granola — Meeting Notes

1. Open Granola
2. Sign in with Google
3. Grant calendar and microphone permissions

---

## 10. App Store Apps

See `apps.md` section (c) for apps that must be installed from the App Store.
Sign in to the Mac App Store first with your Apple ID.

---

---

## Keeping the repo up to date

### Synced automatically (symlinked files)

`~/.zshrc`, `~/.gitconfig`, `~/.tmux.conf`, and all other `_*` dotfiles are
symlinks into the repo. Editing them **is** editing the repo — just `git commit`
when you're happy with a change.

### Synced via `scripts/sync.sh` (non-symlinked configs)

Apps that own their config files (iTerm2, Karabiner, etc.) need to be exported
into the repo manually. A LaunchAgent runs this daily automatically:

```bash
# Run manually anytime
./scripts/sync.sh

# Then review and commit
git diff
git add -p
git commit -m "chore: sync configs"
```

The sync script copies: iTerm2 plist, Karabiner JSON, VS Code extensions list.
It will never touch `claude_desktop_config.json` (sensitive).

### Adding a new app config

**Pattern A — config lives at `~/.*`** (e.g., `~/.newrc`):

1. Copy the live file into the repo root: `cp ~/.newrc _newrc`
2. `git add _newrc`
3. Run `./scripts/symlinks.sh` to create the `~/.newrc` symlink
4. The file is now always in sync via the symlink

**Pattern B — config lives at `~/Library/...`** (e.g., a new app's plist):

1. Copy the file into `_configs/`: `cp ~/Library/.../App.plist _configs/`
2. Add a `sync_file` entry to `scripts/sync.sh` so it stays updated
3. Add a symlink or copy step to `scripts/symlinks.sh` for new machine installs
4. If the file contains secrets, add it to `.gitignore` and create a `.template` version instead

**Pattern C — config lives at `~/.config/<app>/`**:

1. Copy the directory into `_config/`: `cp -r ~/.config/myapp _config/myapp`
2. `git add _config/myapp`
3. Run `./scripts/symlinks.sh` — it will symlink `_config/myapp` → `~/.config/myapp`

---

## Quick Reference

| Credential | Where to find it |
|------------|-----------------|
| SSH private keys | LastPass: SSH Private Keys |
| MCP API keys | LastPass: MCP API Keys |
| BetterTouchTool license | LastPass: BetterTouchTool License |
| Other software licenses | LastPass |
