#!/bin/bash

echo "Installing Hyprland dotfiles..."

sudo pacman -S --needed \
    hyprland \
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
    breeze-snow-cursor-theme \
    ttf-jetbrains-mono-nerd \
    nautilus \
    python \
    glib2 \
    xsettingsd

if [ -d "$HOME/.config/hypr" ]; then
    mv "$HOME/.config/hypr" "$HOME/.config/hypr.bak"
fi
if [ -d "$HOME/.config/waybar" ]; then
    mv "$HOME/.config/waybar" "$HOME/.config/waybar.bak"
fi
if [ -d "$HOME/.config/wofi" ]; then
    mv "$HOME/.config/wofi" "$HOME/.config/wofi.bak"
fi
if [ -d "$HOME/.config/kitty" ]; then
    mv "$HOME/.config/kitty" "$HOME/.config/kitty.bak"
fi
if [ -d "$HOME/.config/dunst" ]; then
    mv "$HOME/.config/dunst" "$HOME/.config/dunst.bak"
fi
if [ -d "$HOME/.config/rofi" ]; then
    mv "$HOME/.config/rofi" "$HOME/.config/rofi.bak"
fi
if [ -d "$HOME/.config/gtk-3.0" ]; then
    mv "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-3.0.bak"
fi
if [ -d "$HOME/.config/gtk-4.0" ]; then
    mv "$HOME/.config/gtk-4.0" "$HOME/.config/gtk-4.0.bak"
fi
if [ -d "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
fi
if [ -f "$HOME/.bashrc" ]; then
    mv "$HOME/.bashrc" "$HOME/.bashrc.bak"
fi

cp -r .config/hypr "$HOME/.config/"
cp -r .config/waybar "$HOME/.config/"
cp -r .config/wofi "$HOME/.config/"
cp -r .config/kitty "$HOME/.config/"
cp -r .config/dunst "$HOME/.config/"
cp -r .config/rofi "$HOME/.config/"
cp -r .config/gtk-3.0 "$HOME/.config/"
cp -r .config/gtk-4.0 "$HOME/.config/"
cp -r .config/nvim "$HOME/.config/"
cp -r .config/xsettingsd "$HOME/.config/"
cp -r .icons "$HOME/"
cp .bashrc "$HOME/"

mkdir -p "$HOME/.local/bin"

sudo cp .local/share/glib-2.0/schemas/10_theme.gschema.override /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

eval "$(starship init bash)" 2>/dev/null || true

echo "Dotfiles installed successfully!"
echo "Restart Hyprland with SUPER+M"

echo "Setting up gwfox Firefox theme..."
./scripts/setup-gwfox.sh
