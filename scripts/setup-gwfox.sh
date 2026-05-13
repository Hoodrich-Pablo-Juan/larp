#!/bin/bash

# setup-gwfox.sh - Installs the gwfox glass theme for Firefox

REPO_URL="https://github.com/akkva/gwfox.git"
TEMP_DIR="/tmp/gwfox-theme"

echo "Setting up gwfox Firefox theme..."

# Clone the repository
if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi
git clone "$REPO_URL" "$TEMP_DIR"

# Find Firefox profile directory
FF_DIR="$HOME/.mozilla/firefox"
if [ ! -d "$FF_DIR" ]; then
    echo "Firefox directory not found. Please run Firefox at least once."
    exit 1
fi

# Find the default profile (usually ends with .default-release or .default)
PROFILE_DIR=$(grep 'Path=' "$FF_DIR/profiles.ini" | head -n 1 | cut -d '=' -f 2)

if [ -z "$PROFILE_DIR" ]; then
    echo "Could not find a Firefox profile."
    exit 1
fi

FULL_PROFILE_PATH="$FF_DIR/$PROFILE_DIR"
CHROME_DIR="$FULL_PROFILE_PATH/chrome"

echo "Installing to profile: $FULL_PROFILE_PATH"

# Create chrome directory if it doesn't exist
mkdir -p "$CHROME_DIR"

# Copy theme files
cp -r "$TEMP_DIR/chrome/"* "$CHROME_DIR/"
cp "$TEMP_DIR/user.js" "$FULL_PROFILE_PATH/" 2>/dev/null || echo "Note: user.js not found in repo, skipping manual preference setup."

# Clean up
rm -rf "$TEMP_DIR"

echo "gwfox theme installed! Please restart Firefox and ensure legacy stylesheets are enabled in about:config."
