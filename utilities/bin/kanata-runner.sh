#!/bin/bash

# Kanata launcher script for LaunchAgent
# This script starts kanata with the configuration file

# Path to kanata binary
KANATA_BIN="/opt/homebrew/bin/kanata"

# Path to kanata configuration file (moved from ~/.config/kanata/config.kbd)
CONFIG_FILE="/Users/kam/dev/projects/dotfiles/_configs/kanata.kbd"

# Check if kanata binary exists
if [ ! -f "$KANATA_BIN" ]; then
    echo "Error: kanata binary not found at $KANATA_BIN"
    exit 1
fi

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: kanata config file not found at $CONFIG_FILE"
    exit 1
fi

# Start kanata with the configuration file using -c flag
exec "$KANATA_BIN" -c "$CONFIG_FILE"