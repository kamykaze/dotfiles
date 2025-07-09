#!/bin/bash

# Kanata launcher script for LaunchDaemons
# This script manages the kanata service via LaunchDaemons (requires sudo)

PLIST_PATH="/Library/LaunchDaemons/com.github.jtroo.kanata.plist"
RUNNER_PATH="/Users/kam/bin/kanata-runner.sh"

if [ -z "$1" ]; then
    echo "Loading kanata service..."
    sudo launchctl load "$PLIST_PATH"
    echo "=== Recent kanata log ==="
    tail -n 20 /tmp/kanata.log
else
    case "$1" in
    unload)
        echo "Unloading kanata service..."
        sudo launchctl unload "$PLIST_PATH"
        ;;
    reload)
        echo "Reloading kanata service..."
        echo "Unloading kanata service..."
        sudo launchctl unload "$PLIST_PATH"
        sleep 2
        echo "Loading kanata service..."
        sudo launchctl load "$PLIST_PATH"
        echo "=== Recent kanata log ==="
        tail -n 20 /tmp/kanata.log
        ;;
    status)
        echo "Checking kanata service status..."
        sudo launchctl list | grep kanata
        if sudo launchctl list | grep -q kanata; then
            echo "✅ Kanata service is loaded."
        else
            echo "❌ Kanata service is NOT loaded."
        fi
        ;;
    debug)
        echo "Debugging kanata service..."
        if [ -f "$RUNNER_PATH" ]; then
            echo "Running kanata runner script..."
            sudo "$RUNNER_PATH"
        else
            echo "Error: kanata runner script not found at $RUNNER_PATH"
            exit 1
        fi
        ;;        
    load|*)
        echo "Loading kanata service..."
        sudo launchctl load "$PLIST_PATH"
        ;;
    esac
fi