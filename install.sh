#!/bin/bash

echo "Installing Hyprland dotfiles..."

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

cp -r .config/hypr "$HOME/.config/"
cp -r .config/waybar "$HOME/.config/"
cp -r .config/wofi "$HOME/.config/"
cp -r .config/kitty "$HOME/.config/"
cp -r .config/dunst "$HOME/.config/"
cp -r .config/rofi "$HOME/.config/"

echo "Dotfiles installed successfully!"
echo "Restart Hyprland with SUPER+M"
