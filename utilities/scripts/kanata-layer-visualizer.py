#!/usr/bin/env python3
"""
Kanata Visual Keyboard Display

Displays a visual representation of your keyboard with the current layer's
mappings, similar to the ASCII layout in your kanata.kbd file.

Usage:
    python3 kanata-visual-kbd.py [--config PATH] [--port PORT] [--debug]

Arguments:
    --config PATH   Path to kanata.kbd config (default: ~/.configs/kanata.kbd)
    --port PORT     TCP port (default: 12321)
    --debug         Show debug messages
"""

import socket
import sys
import json
import re
import os
from pathlib import Path
from blessed import Terminal

KANATA_HOST = '127.0.0.1'
KANATA_PORT = 12321
CONFIG_PATH = os.path.expanduser('~/.configs/kanata.kbd')

class KanataConfigParser:
    """Parse kanata.kbd configuration file to extract layer definitions"""

    def __init__(self, config_path):
        self.config_path = config_path
        self.layers = {}
        self.aliases = {}
        self.source_layout = []
        self.parse_config()

    def parse_config(self):
        """Parse the kanata config file"""
        with open(self.config_path, 'r') as f:
            content = f.read()

        # Parse source layout
        self._parse_source(content)

        # Parse aliases
        self._parse_aliases(content)

        # Parse layers
        self._parse_layers(content)

    def _parse_source(self, content):
        """Extract defsrc layout (the physical keyboard layout)"""
        src_match = re.search(r'\(defsrc\s+(.*?)\n\)', content, re.DOTALL)
        if src_match:
            src_content = src_match.group(1)
            rows = []
            for line in src_content.split('\n'):
                line = line.strip()
                if line and not line.startswith(';;'):
                    keys = line.split()
                    if keys:
                        rows.append(keys)
            self.source_layout = rows

    def _parse_aliases(self, content):
        """Extract defalias definitions"""
        alias_match = re.search(r'\(defalias\s+(.*?)\n\)', content, re.DOTALL)
        if alias_match:
            alias_content = alias_match.group(1)
            # Parse each alias line
            for line in alias_content.split('\n'):
                line = line.strip()
                if line and not line.startswith(';;'):
                    # Match alias name and definition
                    match = re.match(r'(\w+)\s+(.+)', line)
                    if match:
                        name, definition = match.groups()
                        self.aliases[name] = definition.strip()

    def _parse_layers(self, content):
        """Extract deflayer definitions"""
        # Find all deflayer blocks
        layer_pattern = r'\(deflayer\s+(\w+)(.*?)\n\)'
        for match in re.finditer(layer_pattern, content, re.DOTALL):
            layer_name = match.group(1)
            layer_content = match.group(2)

            # Split into rows
            rows = []
            for line in layer_content.split('\n'):
                line = line.strip()
                if line and not line.startswith(';;'):
                    # Extract keys (everything before comment)
                    keys_part = line.split(';;')[0].strip()
                    keys = keys_part.split()
                    if keys:
                        rows.append(keys)

            self.layers[layer_name] = rows

    def get_layer_keys(self, layer_name):
        """Get the key layout for a specific layer"""
        return self.layers.get(layer_name, [])

    def resolve_alias(self, key):
        """Resolve an alias to its definition (for display purposes)"""
        if key.startswith('@'):
            alias_name = key[1:]
            return self.aliases.get(alias_name, key)
        return key

    def get_human_readable_mapping(self, alias_def):
        """Convert alias definition to human-readable format"""
        # Handle tap-hold patterns
        if 'tap-hold-press' in alias_def or 'tap-hold-release' in alias_def:
            # Try to extract tap and hold actions
            # Format: (tap-hold-press time time tap_action hold_action)
            match = re.search(r'\(tap-hold-\w+\s+\S+\s+\S+\s+(\S+)\s+(.+)\)$', alias_def)
            if match:
                tap_action = match.group(1)
                hold_action = match.group(2).rstrip(')')

                # Clean up nested parens
                if hold_action.startswith('('):
                    # It's a complex action
                    if 'layer-toggle' in hold_action:
                        layer = hold_action.split()[-1].rstrip(')')
                        hold_action = f"layer:{layer}"
                    elif 'multi' in hold_action:
                        hold_action = "combo"

                return f"tap:{tap_action} hold:{hold_action}"

        # Handle layer-toggle
        if 'layer-toggle' in alias_def:
            layer = alias_def.split()[-1].rstrip(')')
            return f"→ layer:{layer}"

        # Handle layer-switch
        if 'layer-switch' in alias_def:
            layer = alias_def.split()[-1].rstrip(')')
            return f"switch → {layer}"

        # Handle multi keys
        if 'multi' in alias_def:
            # Extract keys from (multi key1 key2 ...)
            match = re.search(r'\(multi\s+([^)]+)\)', alias_def)
            if match:
                keys = match.group(1).split()
                return f"combo: {'+'.join(keys)}"

        # Handle switch (conditional)
        if 'switch' in alias_def:
            return "conditional (safe-rpt)"

        # Handle caps-word
        if 'caps-word' in alias_def:
            return "Caps Word"

        return alias_def[:40]  # Truncate long definitions


class VisualKeyboard:
    """Render a visual keyboard layout"""

    def __init__(self, term, parser):
        self.term = term
        self.parser = parser
        # Use parsed source layout from config, with fallback to hardcoded
        self.key_labels = self._get_key_labels()

    def _get_key_labels(self):
        """Get the base layer key labels from defsrc in config"""
        if self.parser.source_layout:
            return self.parser.source_layout

        # Fallback to hardcoded layout if defsrc not found
        return [
            ['esc', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12'],
            ['grv', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 'bspc'],
            ['tab', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\\'],
            ['caps', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", 'ret'],
            ['lsft', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 'rsft'],
            ['lctl', 'lalt', 'lmet', 'spc', 'rmet', 'ralt', 'left', 'down', 'up', 'rght'],
        ]

    def _format_key(self, key, base_label):
        """Format a single key for display with color coding"""
        t = self.term

        # Passthrough key
        if key == '_':
            return f'{t.dim}{base_label:^8s}{t.normal}'

        # Blocked key
        if key == '∅':
            return f'{t.red}{"[X]":^8s}{t.normal}'

        # Alias (starts with @)
        if key.startswith('@'):
            alias_def = self.parser.resolve_alias(key)
            # Color code by type
            if 'layer-toggle' in alias_def or 'layer-switch' in alias_def:
                return f'{t.cyan}{key[1:]:^8s}{t.normal}'
            elif 'tap-hold' in alias_def:
                return f'{t.yellow}{key[1:]:^8s}{t.normal}'
            elif 'multi' in alias_def:
                return f'{t.magenta}{key[1:]:^8s}{t.normal}'
            else:
                return f'{t.green}{key[1:]:^8s}{t.normal}'

        # Number or special key
        if key.isdigit() or key in ['kp*', 'del', 'pgup', 'pgdn', 'left', 'right', 'up', 'down']:
            return f'{t.bright_blue}{key:^8s}{t.normal}'

        # Regular key
        return f'{t.white}{key:^8s}{t.normal}'

    def _get_interesting_mappings(self, layer_name):
        """Extract interesting key mappings for the current layer"""
        layer_keys = self.parser.get_layer_keys(layer_name)
        if not layer_keys:
            return []

        mappings = []
        for row_idx, (base_row, key_row) in enumerate(zip(self.key_labels, layer_keys)):
            for base_key, actual_key in zip(base_row, key_row):
                # Skip passthrough keys
                if actual_key == '_':
                    continue

                # Skip function keys on base layer
                if row_idx == 0 and layer_name == 'base':
                    continue

                # Process aliases
                if actual_key.startswith('@'):
                    alias_def = self.parser.resolve_alias(actual_key)
                    readable = self.parser.get_human_readable_mapping(alias_def)
                    mappings.append((base_key, actual_key[1:], readable))
                elif actual_key != base_key and actual_key != '∅':
                    # Direct remapping
                    mappings.append((base_key, actual_key, f"→ {actual_key}"))

        return mappings

    def draw_keyboard(self, layer_name):
        """Draw the keyboard layout for the current layer"""
        t = self.term

        layer_keys = self.parser.get_layer_keys(layer_name)

        if not layer_keys:
            return

        print(t.home + t.clear)
        print(t.bold + t.green + '=' * 100)
        print(f"{'KANATA VISUAL KEYBOARD':^100s}")
        print('=' * 100 + t.normal)
        print()
        print(t.bold + t.yellow + f"Current Layer: {layer_name.upper():^100s}" + t.normal)
        print()

        # Draw each row
        for row_idx, (base_row, key_row) in enumerate(zip(self.key_labels, layer_keys)):
            # Add spacing for visual alignment
            if row_idx == 0:  # Function row
                print(' ' * 2, end='')
            elif row_idx == 2:  # Tab row
                print(' ' * 1, end='')
            elif row_idx == 3:  # Caps row
                print(' ' * 2, end='')
            elif row_idx == 4:  # Shift row
                print(' ' * 3, end='')
            elif row_idx == 5:  # Bottom row
                print(' ' * 4, end='')

            # Draw each key in the row
            for base_key, actual_key in zip(base_row, key_row):
                formatted_key = self._format_key(actual_key, base_key)
                print(formatted_key, end=' ')
            print()

        # Legend
        print()
        print(t.dim + '─' * 100 + t.normal)
        print(t.bold + "Legend:" + t.normal)
        print(f"  {t.dim}unchanged{t.normal}  {t.cyan}layer{t.normal}  {t.yellow}tap-hold{t.normal}  {t.magenta}combo{t.normal}  {t.bright_blue}number/nav{t.normal}  {t.red}[X] blocked{t.normal}")

        # Detailed key mappings
        mappings = self._get_interesting_mappings(layer_name)
        if mappings:
            print()
            print(t.bold + t.cyan + "Key Mappings:" + t.normal)
            print(t.dim + '─' * 100 + t.normal)

            # Split into two columns
            mid = (len(mappings) + 1) // 2
            col1 = mappings[:mid]
            col2 = mappings[mid:]

            for i in range(max(len(col1), len(col2))):
                # Left column
                if i < len(col1):
                    base_key, _, readable = col1[i]
                    left = f"  {t.bold}{base_key:6s}{t.normal} → {readable:40s}"
                else:
                    left = " " * 50

                # Right column
                if i < len(col2):
                    base_key, _, readable = col2[i]
                    right = f"{t.bold}{base_key:6s}{t.normal} → {readable}"
                else:
                    right = ""

                print(left + "  " + right)

        print()
        print(t.dim + f"Connected to Kanata at {KANATA_HOST}:{KANATA_PORT}")
        print(f"Config: {self.parser.config_path}")
        print("Press Ctrl+C to exit" + t.normal)


def connect_to_kanata(host, port):
    """Connect to Kanata TCP server"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((host, port))
        return sock
    except ConnectionRefusedError:
        print(f"Error: Cannot connect to Kanata at {host}:{port}")
        print("\nMake sure Kanata is running with TCP port enabled:")
        print(f"  sudo kanata -c ~/.configs/kanata.kbd -p {port}")
        sys.exit(1)
    except Exception as e:
        print(f"Error connecting to Kanata: {e}")
        sys.exit(1)


def parse_layer_change(message):
    """Parse layer change message from Kanata"""
    try:
        data = json.loads(message)
        if 'LayerChange' in data and 'new' in data['LayerChange']:
            return data['LayerChange']['new']
    except (json.JSONDecodeError, KeyError, TypeError):
        pass
    return None


def main():
    # Parse arguments
    config_path = CONFIG_PATH
    port = KANATA_PORT
    debug_mode = False

    for i, arg in enumerate(sys.argv[1:]):
        if arg == '--config' and i + 2 < len(sys.argv):
            config_path = os.path.expanduser(sys.argv[i + 2])
        elif arg == '--port' and i + 2 < len(sys.argv):
            port = int(sys.argv[i + 2])
        elif arg == '--debug':
            debug_mode = True

    # Verify config exists
    if not os.path.exists(config_path):
        print(f"Error: Config file not found: {config_path}")
        print("\nSpecify config path with: --config PATH")
        sys.exit(1)

    term = Terminal()

    print(term.home + term.clear)
    print("Loading Kanata configuration...")

    # Parse config
    parser = KanataConfigParser(config_path)

    print(f"Loaded {len(parser.layers)} layers: {', '.join(parser.layers.keys())}")
    print("Connecting to Kanata...")

    # Connect to Kanata
    sock = connect_to_kanata(KANATA_HOST, port)

    # Create visual keyboard
    kbd = VisualKeyboard(term, parser)

    current_layer = 'base'
    kbd.draw_keyboard(current_layer)

    buffer = ""
    try:
        while True:
            data = sock.recv(1024).decode('utf-8')
            if not data:
                break

            if debug_mode:
                print(f"\n[DEBUG] Received: {repr(data)}")

            buffer += data
            lines = buffer.split('\n')
            buffer = lines[-1]

            for line in lines[:-1]:
                if not line.strip():
                    continue

                if debug_mode:
                    print(f"[DEBUG] Processing: {line}")

                layer = parse_layer_change(line)
                if layer:
                    if debug_mode:
                        print(f"[DEBUG] Layer changed to: {layer}")
                    current_layer = layer
                    kbd.draw_keyboard(current_layer)

    except KeyboardInterrupt:
        print(term.normal + "\n\nExiting...")
    finally:
        sock.close()


if __name__ == '__main__':
    try:
        from blessed import Terminal
    except ImportError:
        print("Error: 'blessed' package not found")
        print("\nInstall it with:")
        print("  pip3 install blessed")
        sys.exit(1)

    main()
