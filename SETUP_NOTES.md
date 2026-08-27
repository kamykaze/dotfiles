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

### Step 2 — Restore your SSH keys (recommended before install.sh)

Not strictly required, but do it now if you can — see [section 1](#1-ssh-keys).
The last thing `install.sh` does is switch this repo's remote from HTTPS to SSH,
so without keys in place your first `git push` will fail.

### Step 3 — Run install.sh

```bash
./install.sh
```

It opens with a preflight summary and waits for you to type `yes`. That prompt
exists because it is very easy to run this before reading these notes. Skip it on
re-runs with `./install.sh --yes` (or `DOTFILES_ASSUME_YES=1`).

This will: install Xcode CLT (if missing), install Homebrew and all packages from
the Brewfile, create all dotfile symlinks, check VS Code config, install the git
hooks, and wire up the Kanata LaunchAgent.

It does **not** apply macOS system preferences — that's the next step.

Existing dotfiles that aren't already symlinks are skipped, never overwritten.

### Step 4 — Apply macOS system preferences

```bash
bash scripts/macos.sh
```

Deliberately not part of `install.sh` — it rewrites trackpad, keyboard, Finder
and Dock behaviour, and restarts Finder and Dock, so it's opt-in.

**Don't skip it.** Besides applying your preferences, it writes a stamp at
`~/.local/state/dotfiles/macos-applied`. Until that stamp exists, `scripts/sync.sh`
refuses to sync macOS preferences back into the repo — otherwise the daily sync
LaunchAgent would overwrite every curated value with this machine's factory
defaults. See [the sync guards](#guards-on-a-freshly-imaged-mac).

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

## 2. Claude Desktop — Sign In

Just install the cask and sign in. There is **nothing to copy from this repo.**

- Connectors (ClickUp, Gmail, Drive, Slack, …) are hosted and follow your
  account — no local MCP server config, no API keys to restore.
- `~/Library/Application Support/Claude/claude_desktop_config.json` is written
  by the app and holds machine-specific state (device name, per-account flags,
  pinned/starred sessions). **Never copy a repo version over it** — the app owns
  that file. This repo used to ship a `.template` for it; that was a mistake and
  it has been removed.

Only these preferences are worth re-setting by hand, all in the app's settings UI:

| Preference | Value |
|------------|-------|
| Show in menu bar | on |
| Quick entry shortcut | `Alt+Space` |
| Sidebar mode | chat |
| Web search in Cowork | on |

---

## 3. BetterTouchTool

`install.sh` imports the preset automatically via `bttcli`, but BTT needs
two things set up first:

1. Open BetterTouchTool and enter your license key from LastPass
2. Go to **Settings → Scripting → Command Line / Socket Server** and enable it
3. Restart BetterTouchTool
4. Re-run `./install.sh` (or just the import step: `bttcli import_preset path=bettertouchtool/kam_btt_presets.bttpreset`)

The socket server setting is stored in BTT's own preferences, not in the
preset file, so it must be enabled manually on each new machine. It is also
required for `scripts/sync.sh` to export preset changes back to the repo.

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

## 9. Travel Mode — `lidguard`

Keeps the MacBook awake with the **lid closed** so it stays reachable remotely
(e.g. Claude dispatch) while you carry it, with automatic safety cutoffs.

`install.sh` symlinks `utilities/bin/lidguard` → `~/.local/bin/lidguard` (on PATH).
Nothing runs in the background — it's an on-demand script you start when traveling.

```bash
sudo lidguard          # enter travel mode + monitor (prompts for password once)
                       # ...close the lid. Press Ctrl-C to end travel mode.
sudo lidguard --hotspot  # ...and also switch Wi-Fi to the iPhone hotspot (opt-in)
lidguard status        # one-shot readout (add sudo to also read thermal pressure)
```

**What it does:** sets `pmset disablesleep 1` (the only reliable way to stop
lid-close sleep) plus `womp`/`tcpkeepalive` for network wake, then every 30s
checks thermal pressure and battery. By default it leaves **Wi-Fi alone** (so you
can close the lid and coast on your current network as you head out); pass
`--hotspot` to switch to your iPhone hotspot (see below).

- **Thermal pressure reaches the trigger level** → forces `pmset sleepnow`, keeps
  travel mode on, resumes monitoring after wake. macOS 26 removed the raw °C sensor
  (`smc` sampler) on Apple Silicon, so `lidguard` uses macOS's own **thermal pressure**
  signal instead — the ladder is `Nominal < Fair/Moderate < Serious/Heavy <
  Critical/Trapping < Sleeping`. Default trigger: **Critical** — lets heavy
  jobs run and bails just before macOS's own thermal-emergency sleep (override
  with `LIDGUARD_THERMAL_TRIGGER`, e.g. `serious` to bail earlier).
- **Battery < 15%** (on battery power) → restores normal sleep, sleeps, and **exits**
  travel mode so the Mac stays asleep and protects the battery.

An exit trap **always** restores normal sleep (`disablesleep 0`) on Ctrl-C or crash,
so the Mac is never left unable to sleep.

**Wi-Fi hotspot switch (opt-in, `--hotspot`):** off by default — plain `sudo lidguard`
never touches Wi-Fi, so you can start it, close the lid, and stay on your current
network for a few minutes as you leave. Run `sudo lidguard --hotspot` when you want it
to join your iPhone hotspot (`Kam's iPhone 17 PX`) via `networksetup` on start and
cycle Wi-Fi off/on on stop so macOS auto-rejoins your preferred networks (the legacy
`airport -z` disassociate was removed in macOS 26, so a power cycle is the reliable way
back). Requirements/notes:

- **Expect an admin-password prompt on start.** Joining the hotspot reads its saved
  Wi-Fi password from the macOS **System keychain**, and macOS gates that read with an
  admin-password dialog *every time* — there is no "remember" option for System-keychain
  reads, and the login-keychain workaround doesn't help because the root monitor process
  can't reach the GUI login keychain. So each `sudo lidguard` pops a password prompt when
  it switches Wi-Fi. Known limitation of `networksetup` on macOS 26; accepted for now.
- The hotspot must already be a **saved network** (join it once manually so macOS
  remembers the password). If it isn't, `lidguard` logs a warning and skips the switch.
- Make sure Personal Hotspot is on / in range when you start — `networksetup` can't wake
  a dormant Instant Hotspot over Bluetooth the way the Wi-Fi menu does; if it's not
  broadcasting, the join just warns and travel mode continues.
- `--hotspot` enables it for one run; set `LIDGUARD_HOTSPOT=1` to make it the default
  again. Point it at a different hotspot with `LIDGUARD_HOTSPOT_MATCH` (a regex matched
  against saved networks).

**Tuning** (env overrides): `LIDGUARD_THERMAL_TRIGGER`, `LIDGUARD_BATT_MIN`,
`LIDGUARD_INTERVAL`, `LIDGUARD_HOTSPOT`, `LIDGUARD_HOTSPOT_MATCH`. **Log:**
`~/Library/Logs/lidguard.log` records what triggered each sleep and each Wi-Fi
switch, so it's visible after the fact.

**First-run check (Apple Silicon):** confirm the thermal sampler works with
`sudo powermetrics -n 1 -i 500 --samplers thermal`. It should print a
`Current pressure level:` line. If not, `lidguard` logs a warning and runs
battery-only.

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

Apps that own their config files (Karabiner, etc.) need to be exported
into the repo manually. A LaunchAgent runs this daily automatically:

```bash
# Run manually anytime
./scripts/sync.sh

# Then review and commit
git diff
git add -p
git commit -m "chore: sync configs"
```

The sync script copies: VS Code settings/keybindings/extensions snapshots,
BetterTouchTool presets, and macOS system preferences. It will never touch
`claude_desktop_config.json` (app-owned).

**Sync direction is one-way: machine -> repo.** Nothing it writes is symlinked back.

#### Guards on a freshly-imaged Mac

Because sync reads live state, running it before a machine is fully provisioned
would capture *un-configured* state as the new source of truth — and the daily
LaunchAgent would do it silently. Two guards prevent that:

| Guard | Behaviour |
|-------|-----------|
| macOS preferences | Skipped entirely until `scripts/macos.sh` has been run on this machine. It writes a stamp at `~/.local/state/dotfiles/macos-applied`; without it, sync would replace every curated `defaults write` value with macOS factory defaults. |
| VS Code extensions | Additions are recorded, but an extension missing locally is **kept** in the snapshot rather than dropped — a half-finished `brew bundle` shouldn't shrink the list. The withheld names are printed. |

Pass `--force` to override both (`./scripts/sync.sh --force`) — only correct once
you're sure the live machine really is the state you want recorded.

**On a new machine, run `bash scripts/macos.sh` before your first sync.**

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
| BetterTouchTool license | LastPass: BetterTouchTool License |
| Other software licenses | LastPass |

---

## Troubleshooting

### `Refusing to load formula ... from untrusted tap`

Homebrew 6 requires third-party (non-`homebrew/*`) taps to be explicitly trusted
before it will load a formula from them, so a fresh machine used to stop here:

```
Error: Refusing to load formula armmbed/formulae/arm-none-eabi-gcc from untrusted tap armmbed/formulae.
```

The `Brewfile` now declares this inline, so `brew bundle` applies the trust itself:

```ruby
tap "armmbed/formulae", trusted: { formulae: ["arm-none-eabi-gcc"] }
```

If you add a new formula or cask from a third-party tap, add it to that tap's
`trusted:` list too (`casks: [...]` for casks). To check the current trust store:

```bash
brew trust --json v1
```

Note: `brew bundle` aborts on the first failure and `install.sh` uses `set -e`,
so a Brewfile error means the later steps (symlinks, submodules, VS Code, BTT,
launch agents) never ran. Just re-run `./install.sh` after fixing — every script
is idempotent.
