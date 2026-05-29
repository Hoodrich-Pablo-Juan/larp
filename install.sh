#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit

echo "Installing Hyprland dotfiles..."

# Fix pacman.conf if it was broken by previous runs
sudo sed -i '/\[chaotic-aur\]/,/Include/d' /etc/pacman.conf

# Enable multilib
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

# Add Chaotic-AUR (Most Robust method)
if ! grep -q "chaotic-aur" /etc/pacman.conf; then
    echo "Adding Chaotic-AUR repository..."
    sudo pacman-key --init
    sudo pacman-key --populate archlinux

    KID="3056513887B78AEB"
    KSUCCESS=false
    
    # Try direct download first from official source
    echo "Attempting direct key download..."
    if curl -sL https://aur.chaotic.cx/chaotic.gpg -o chaotic.gpg && [ -s chaotic.gpg ]; then
        # Check if it's actually a GPG key or an HTML error page
        if file chaotic.gpg | grep -q "public key"; then
            if sudo pacman-key --add chaotic.gpg && sudo pacman-key --lsign-key "$KID"; then
                KSUCCESS=true
            fi
        fi
        rm -f chaotic.gpg
    fi

    # Fallback to keyservers if direct download fails
    if [ "$KSUCCESS" = false ]; then
        echo "Direct download failed or invalid. Trying keyservers..."
        for server in hkp://keyserver.ubuntu.com:80 hkps://keyserver.ubuntu.com hkp://pgp.mit.edu; do
            echo "Trying $server..."
            if sudo pacman-key --recv-key "$KID" --keyserver "$server" && sudo pacman-key --lsign-key "$KID"; then
                KSUCCESS=true
                break
            fi
        done
    fi

    if [ "$KSUCCESS" = true ]; then
        sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
        echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
        sudo pacman-key --populate chaotic
    else
        echo "CRITICAL ERROR: Could not fetch Chaotic-AUR keys ($KID). Installation aborted."
        exit 1
    fi
fi

# Update system
sudo pacman -Sy

# Install dependencies (swaybg for wallpaper, removal of unused bar)
sudo pacman -S --needed \
    hyprland \
    hypridle \
    waybar \
    wofi \
    kitty \
    dunst \
    rofi \
    jq \
    starship \
    gtk3 \
    gtk4 \
    papirus-icon-theme \
    ttf-jetbrains-mono-nerd \
    nautilus \
    python \
    glib2 \
    xsettingsd \
    brightnessctl \
    libpulse \
    polkit-gnome \
    wget \
    curl \
    bluez \
    bluez-utils \
    blueman \
    unzip \
    binutils \
    swaybg \
    librewolf

# Enable Bluetooth
sudo systemctl enable --now bluetooth

# Install cursor theme
if command -v yay &> /dev/null; then
    yay -S --needed --noconfirm breeze-snow-cursor-theme
fi

# LibreWolf Policies (Extensions & Theme Prep)
sudo mkdir -p /usr/lib/librewolf/distribution
cat <<EOF | sudo tee /usr/lib/librewolf/distribution/policies.json
{
  "policies": {
    "ExtensionSettings": {
      "uBlock0@raymondhill.net": {
        "installation_mode": "force_installed",
        "install_url": "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
      },
      "{d774031d-27dd-4b7b-9447-0d60317e07a3}": {
        "installation_mode": "force_installed",
        "install_url": "https://addons.mozilla.org/firefox/downloads/latest/vimium-c/latest.xpi"
      },
      "addon@darkreader.org": {
        "installation_mode": "force_installed",
        "install_url": "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi"
      }
    },
    "Preferences": {
      "toolkit.legacyUserProfileCustomizations.stylesheets": true,
      "svg.context-properties.content.enabled": true,
      "browser.tabs.drawInTitlebar": true,
      "browser.uidensity": 0,
      "layers.acceleration.force-enabled": true,
      "mozilla.widget.use-libdecor-geometry-extension": true,
      "network.cookie.lifetimePolicy": 0,
      "privacy.clearOnShutdown.cookies": false,
      "privacy.clearOnShutdown.siteSettings": false,
      "privacy.sanitize.sanitizeOnShutdown": false,
      "privacy.cpd.cookies": false,
      "privacy.cpd.siteSettings": false
    }
  }
}
EOF

# Install gwfox theme
echo "Downloading gwfox theme..."
rm -rf /tmp/gwfox
git clone --depth 1 https://github.com/akkva/gwfox.git /tmp/gwfox

# Install waybar-autohide
echo "Installing waybar-autohide..."
cp .config/waybar/waybar-simple-autohide.sh ~/.config/waybar/
chmod +x ~/.config/waybar/waybar-simple-autohide.sh

# Apply theme to ALL profiles found in .librewolf
if [ -d "$HOME/.librewolf" ]; then
    echo "Searching for LibreWolf profiles..."
    # Find directories inside .librewolf that are likely profiles (contain a dot and are not 'Profile Groups')
    find "$HOME/.librewolf" -mindepth 1 -maxdepth 1 -type d -name "*.*" ! -name "Profile Groups" | while read -r profile; do
        echo "Found profile: $profile"
        mkdir -p "${profile}/chrome"
        # The gwfox repo has .css files in the root
        cp /tmp/gwfox/userChrome.css "${profile}/chrome/" 2>/dev/null || true
        cp /tmp/gwfox/userContent.css "${profile}/chrome/" 2>/dev/null || true
        # Also copy user.js if it exists in the repo
        cp /tmp/gwfox/user.js "${profile}/user.js" 2>/dev/null || true
        
        # Create user.js with cookie preservation settings if it doesn't exist
        if [ ! -f "${profile}/user.js" ]; then
            cat <<'USERJS' > "${profile}/user.js"
// LibreWolf user.js - Preserve cookies on exit
user_pref("network.cookie.lifetimePolicy", 0);
user_pref("privacy.clearOnShutdown.cookies", false);
user_pref("privacy.clearOnShutdown.siteSettings", false);
user_pref("privacy.sanitize.sanitizeOnShutdown", false);
user_pref("privacy.cpd.cookies", false);
user_pref("privacy.cpd.siteSettings", false);
USERJS
        fi
        
        # Add font fix to userContent.css to prevent monospace font issue
        if [ -f "${profile}/chrome/userContent.css" ]; then
            # Check if font fix already exists
            if ! grep -q "Fix monospace font issue" "${profile}/chrome/userContent.css"; then
                sed -i '1,/^:root {/ a\
/* Fix monospace font issue - use system default fonts (preserves icons) */\
body, \
input:not([type="checkbox"]):not([type="radio"]),\
button:not(.toolbarbutton-1),\
select,\
textarea,\
label:not(.checkbox-label):not(.radio-label),\
p:not(.checkbox-label):not(.radio-label),\
span:not(.checkbox-label):not(.radio-label):not(.icon),\
div:not(.checkbox-container):not(.radio-container),\
li,\
ul,\
ol,\
h1, h2, h3, h4, h5, h6,\
.aHTMLTooltip,\
.tooltip {\
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif !important;\
}\
' "${profile}/chrome/userContent.css"
            fi
        fi
        
        # Add font fix to userChrome.css to prevent monospace font issue
        if [ -f "${profile}/chrome/userChrome.css" ]; then
            # Check if font fix already exists
            if ! grep -q "Fix monospace font issue" "${profile}/chrome/userChrome.css"; then
                sed -i '1,/^@namespace xul/ a\
/* Fix monospace font issue - use system default fonts (preserves icons) */\
body, \
input:not(.textbox-input):not([type="checkbox"]):not([type="radio"]),\
button:not(.toolbarbutton-1),\
select,\
textarea,\
.textbox-input,\
label:not(.checkbox-label):not(.radio-label),\
p:not(.checkbox-label):not(.radio-label),\
span:not(.checkbox-label):not(.radio-label):not(.icon),\
div:not(.checkbox-container):not(.radio-container),\
li,\
ul,\
ol,\
h1, h2, h3, h4, h5, h6,\
.aHTMLTooltip,\
.tooltip,\
.menupopup-text,\
.menulist-text,\
.menulist-label,\
.menuitem-text,\
.menuitem-label,\
.description {\
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif !important;\
}\
' "${profile}/chrome/userChrome.css"
            fi
        fi
        echo "Applied gwfox theme to $profile"
    done
fi

# Store a copy for new profiles
mkdir -p "$HOME/.local/share/gwfox"
cp -r /tmp/gwfox/* "$HOME/.local/share/gwfox/"

# Create theme applier script
cat <<'EOF' > "$HOME/.local/bin/apply-gwfox"
#!/bin/bash
if [ -d "$HOME/.librewolf" ]; then
    echo "Applying gwfox theme to LibreWolf profiles..."
    find "$HOME/.librewolf" -mindepth 1 -maxdepth 1 -type d -name "*.*" ! -name "Profile Groups" | while read -r profile; do
        mkdir -p "${profile}/chrome"
        cp "$HOME/.local/share/gwfox/userChrome.css" "${profile}/chrome/" 2>/dev/null || true
        cp "$HOME/.local/share/gwfox/userContent.css" "${profile}/chrome/" 2>/dev/null || true
        cp "$HOME/.local/share/gwfox/user.js" "${profile}/user.js" 2>/dev/null || true
        echo "Applied to: $profile"
    done
    echo "Done. Restart LibreWolf."
else
    echo "LibreWolf directory not found."
fi
EOF
chmod +x "$HOME/.local/bin/apply-gwfox"

# Copy configs
cp -r .config/hypr "$HOME/.config/"
cp -r .config/waybar "$HOME/.config/"
cp -r .config/wofi "$HOME/.config/"
cp -r .config/kitty "$HOME/.config/"
cp -r .config/dunst "$HOME/.config/"
cp -r .config/rofi "$HOME/.config/"
cp -r .config/gtk-3.0 "$HOME/.config/"
cp -r .config/gtk-4.0 "$HOME/.config/"
cp -r .config/xsettingsd "$HOME/.config/"
cp -r .icons "$HOME/"
if [ -d "wallpapers" ]; then
    cp -r wallpapers "$HOME/"
else
    echo "Warning: wallpapers directory not found in current folder."
fi
cp .bashrc "$HOME/"

# Setup local bin
mkdir -p "$HOME/.local/bin"

# Create toggle-laptop.sh
cat <<'EOF' > "$HOME/.local/bin/toggle-laptop.sh"
#!/bin/bash
# Script to toggle the laptop display eDP-1

# Check if eDP-1 is in the ACTIVE monitors list
if hyprctl monitors | grep -q "eDP-1"; then
    echo "eDP-1 is active. Disabling it..."
    hyprctl keyword monitor "eDP-1, disable"
else
    echo "eDP-1 is not active. Enabling it..."
    # Re-enable centered below the 3440x1440@1.5 monitor (at 180Hz)
    # Positioning it at 64x1440 to center it
    hyprctl keyword monitor "eDP-1, 2880x1800@120, 64x1440, 1.33"
fi
EOF
chmod +x "$HOME/.local/bin/toggle-laptop.sh"

# Path Fixes
find "$HOME/.config/hypr" -type f -exec sed -i "s|/home/larp|$HOME|g" {} +

# Setup swaybg for wallpaper
# (Config update in hyprland.conf needed)

# GTK theme
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

# Init Starship
if [ -f "$HOME/.bashrc" ] && ! grep -q "starship init bash" "$HOME/.bashrc"; then
    echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
fi

# Ensure ~/.local/bin is in PATH
if [ -f "$HOME/.bashrc" ] && ! grep -q ".local/bin" "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "Installation complete. Restart Hyprland!"
