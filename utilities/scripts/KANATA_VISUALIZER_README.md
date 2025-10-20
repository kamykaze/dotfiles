# Kanata Layer Visualizer

Real-time visual keyboard display showing your active Kanata layer and key mappings.

## Overview

This visualizer shows which Kanata layer you're currently on with a full visual keyboard layout - perfect for keeping as a reference while learning your custom layout or debugging layer switching.

## Visual Keyboard Visualizer - `kanata-layer-visualizer.py`

**Features:**
- **Visual keyboard layout** - See keys arranged like your physical keyboard
- **Real-time layer updates** - Updates instantly when you switch layers
- **Color-coded keys** - Different colors for layer triggers, tap-hold keys, numbers, etc.
- **Auto-parses your config** - Reads your kanata.kbd file to show exact mappings
- **Works as a background service** - Connects via TCP while Kanata runs

**Requirements:**
```bash
pip3 install blessed
```

**Usage:**

1. Start Kanata with TCP port enabled:
```bash
sudo kanata -c ~/.configs/kanata.kbd -p 12321
```

2. In a separate terminal, run the visualizer:
```bash
python3 ~/personal/projects/dotfiles/utilities/scripts/kanata-layer-visualizer.py
```

3. Optional: Specify custom config path:
```bash
python3 kanata-layer-visualizer.py --config /path/to/kanata.kbd
```

4. Debug mode (to see raw TCP messages):
```bash
python3 kanata-layer-visualizer.py --debug
```

**Create an alias in your `~/.zshrc`:**
```bash
alias kanata-viz='python3 ~/personal/projects/dotfiles/utilities/scripts/kanata-layer-visualizer.py'
```

## Alternative: Simple Log Monitor - `kanata-layer-visualizer-simple.sh`

A basic bash version that monitors Kanata logs (limited on macOS).

**Usage:**
```bash
./utilities/scripts/kanata-layer-visualizer-simple.sh
```

## Visual Display Example

When you run the visualizer, you'll see a full keyboard layout like this:

```
====================================================================================================
                                  KANATA VISUAL KEYBOARD
====================================================================================================

                               Current Layer: NAVIGATION

   Esc      F1       F2       F3       F4       F5       F6       F7       F8       F9      F10      F11      F12
  `        1        2        3        4        5        6        7        8        9        0       -        =      Bksp
 num       Q        W       jum       R        T        Y       pwrd      up      nwrd     pgup     [        ]       \
  cwcl     A        S        D        F        G        H      left     down     rght     pgdn      '      Ret
   Shft     Z        X        C        V        B        N       ptab      ,      ntab      /      Shft
    Ctrl     Alt     Meta              nav                      Meta      Alt      ←        ↓       ↑        →

────────────────────────────────────────────────────────────────────────────────────────────────────
Legend:
  unchanged  layer  tap-hold  combo  number/nav  [X] blocked

Connected to Kanata at 127.0.0.1:12321
Config: /Users/kam/.configs/kanata.kbd
Press Ctrl+C to exit
```

### Color Coding

Keys are color-coded to help you identify their function:

- **Dim gray** - Unchanged keys (passthrough from base layer)
- **Cyan** - Layer switching keys (e.g., `num`, `nav`, `jum`)
- **Yellow** - Tap-hold keys (home row modifiers, layer toggles)
- **Magenta** - Multi-key combinations
- **Bright blue** - Numbers and navigation keys
- **Red [X]** - Blocked/disabled keys

## Modifying Your Kanata Launch Daemon

To make Kanata start automatically with TCP support, update your launch daemon:

**Edit:** `~/Library/LaunchAgents/com.github.jtroo.kanata.plist`

Or the file at: `utilities/launchdaemons/com.github.jtroo.kanata.plist`

Add the `-p` flag to the arguments:

```xml
<key>ProgramArguments</key>
<array>
    <string>/usr/local/bin/kanata</string>
    <string>-c</string>
    <string>/Users/yourusername/.configs/kanata.kbd</string>
    <string>-p</string>
    <string>12321</string>
</array>
```

Then reload the daemon:
```bash
launchctl unload ~/Library/LaunchAgents/com.github.jtroo.kanata.plist
launchctl load ~/Library/LaunchAgents/com.github.jtroo.kanata.plist
```

## All Layers Supported

The visualizer automatically detects and displays all layers in your config:

- **base** - Home row modifiers and layer triggers
- **numbers** - Number pad layout
- **navigation** - Arrow keys, page up/down, word navigation
- **shortcuts** - Meh/Hyper key combinations
- **symbols** - Special characters on home row
- **jump** - Layer switching hub
- **mirror** - One-handed mirrored layout
- **plain** - Normal keyboard behavior
- **disabled** - Keyboard locked

## Tips

1. **Run in a separate terminal/tmux pane** - Keep the visualizer visible while working
2. **Use with multiple monitors** - Display on a secondary screen as a reference
3. **Learning tool** - Great for memorizing your custom layer mappings
4. **Debugging** - Verify layer switches are working as expected
5. **Try different layers** - Hold Tab for numbers, Space for navigation, Esc for shortcuts, etc.

## Troubleshooting

**"Cannot connect to Kanata"**
- Make sure Kanata is running: `pgrep kanata`
- Verify TCP port is enabled: `sudo kanata -c ~/.configs/kanata.kbd -p 12321`
- Check the port number matches (default: 12321)

**"blessed package not found"**
- Install it: `pip3 install blessed`

**"Config file not found"**
- Specify config path: `--config ~/.configs/kanata.kbd`
- Or update the `CONFIG_PATH` variable in the script

**Layer not updating**
- Make sure `log-layer-changes yes` is in your kanata.kbd config (it is by default)
- Verify you're actually switching layers (press and hold layer triggers)
- Try debug mode: `--debug`

**Formatting/color issues**
- Make sure you're using a terminal with color support
- Try a different terminal emulator (iTerm2, Alacritty, etc.)

## Advanced: Creating a Menu Bar App

If you want to create a macOS menu bar app that shows the current layer, you could use this script with tools like:
- **SwiftBar** - Display output in menu bar
- **BitBar** - Similar to SwiftBar
- **Custom Swift/Objective-C app** - Connect to TCP port and show in menu bar

Example SwiftBar script concept:
```bash
#!/bin/bash
# Connect to Kanata TCP and show current layer in menu bar
echo "Layer: $(echo 'get_layer' | nc localhost 12321)"
```

## Technical Details

**How it works:**
1. Parses your kanata.kbd configuration file to extract layer definitions
2. Connects to Kanata's TCP server (port 12321 by default)
3. Listens for `LayerChange` JSON messages: `{"LayerChange":{"new":"layer_name"}}`
4. Renders the keyboard layout with the active layer's key mappings
5. Updates the display in real-time as you switch layers

**Config parsing:**
- Extracts `deflayer` blocks to get key layouts
- Parses `defalias` definitions to show what aliases do
- Maintains the visual structure from your config file
