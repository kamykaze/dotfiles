#!/usr/bin/env bash
set -e

echo "-> Applying macOS system preferences..."

# Close System Preferences to avoid overwrite
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# ============================================================
# Keyboard
# ============================================================
echo "  Keyboard: fast key repeat..."
# Key repeat rate (lower = faster; 2 is very fast, 6 is default)
defaults write NSGlobalDomain KeyRepeat -int 5
# Delay before key repeat kicks in (lower = shorter; 15 is default)
defaults write NSGlobalDomain InitialKeyRepeat -int 25
# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# Disable auto-capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# ============================================================
# Trackpad
# ============================================================
echo "  Trackpad: tap to click..."
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# Natural scroll direction (matches iOS — disable if you prefer classic)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# ============================================================
# Dock
# ============================================================
echo "  Dock: preferences..."
# Dock icon size (pixels)
defaults write com.apple.dock tilesize -int 48
# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false
# Don't animate opening applications
defaults write com.apple.dock launchanim -bool false
# Minimize windows into their application icon
defaults write com.apple.dock minimize-to-application -bool true
# Auto-hide dock (set to false if you want it always visible)
defaults write com.apple.dock autohide -bool false

# ============================================================
# Finder
# ============================================================
echo "  Finder: preferences..."
# Show path bar
defaults write com.apple.finder ShowPathbar -bool true
# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true
# Show full POSIX path in title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# Default view: list (Nlsv = list, icnv = icon, clmv = column, Flwv = gallery)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true
# Disable warning on file extension change
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Expand save dialog by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# ============================================================
# Screenshots
# ============================================================
echo "  Screenshots: save to ~/Desktop..."
defaults write com.apple.screencapture location -string "${HOME}/Desktop"
# Save as PNG
defaults write com.apple.screencapture type -string "png"
# Disable shadow on screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# ============================================================
# Menu Bar / UI
# ============================================================
echo "  UI: preferences..."
# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -bool true
# Disable saving to iCloud by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# ============================================================
# Restart affected apps
# ============================================================
echo "  Restarting Finder and Dock..."
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

echo "  Done. Some settings require a logout/restart to take effect."
