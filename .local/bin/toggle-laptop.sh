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
