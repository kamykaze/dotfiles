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
# Most multi-finger gestures are disabled here because BetterTouchTool
# handles custom gestures. Enable them in BTT instead of System Settings.
# ============================================================
echo "  Trackpad: preferences..."

# Tracking speed (0=slow, 3=fast; live value: 2.012896)
defaults write -g com.apple.trackpad.scaling -float 2.012896

# Click threshold: 0=light, 1=medium, 2=firm
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0

# Tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Force click: suppressed (silent click only)
defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool true
defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0

# Secondary click: two-finger click (1=enabled), no corner click (0)
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

# Natural scroll: off (classic direction — BetterTouchTool manages scroll behavior)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# --- Gestures disabled (managed by BetterTouchTool instead) ---
# Note: must write to both domains — macOS prefers the bluetooth trackpad domain for built-in trackpads

# Pinch to zoom: off
defaults write com.apple.AppleMultitouchTrackpad TrackpadPinch -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadPinch -bool false
# Smart zoom (two-finger double-tap): off
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerDoubleTapGesture -bool false
# Rotate: off
defaults write com.apple.AppleMultitouchTrackpad TrackpadRotate -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRotate -bool false
# Look up / data detectors (three-finger tap): off
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 0
# Swipe between pages (two-finger horizontal): off
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false
# Swipe between full-screen apps (three-finger horizontal): off
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 0
# Mission Control / App Expose (three-finger vertical): off
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 0
# Four-finger horizontal swipe: off
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 0
# Four-finger vertical swipe: off
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 0
# Launchpad pinch (four/five finger): off
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerPinchGesture -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture -bool false

# Notification Centre swipe (two-finger from right edge): on (value 3)
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 3
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 3

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
