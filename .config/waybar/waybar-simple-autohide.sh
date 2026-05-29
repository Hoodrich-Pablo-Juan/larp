#!/bin/bash

# Simple and reliable Waybar autohide
# Kills Waybar to hide, launches when cursor near top

HIDE_THRESHOLD=50
REFRESH_RATE=0.2
MONITOR_Y_OFFSET=1440

# Start Waybar initially
waybar &
last_state="shown"

echo "Waybar autohide started. Monitor offset: $MONITOR_Y_OFFSET, Threshold: $HIDE_THRESHOLD"

while true; do
    # Get cursor position
    cursor_data=$(hyprctl cursorpos 2>/dev/null)
    if [ -z "$cursor_data" ]; then
        sleep "$REFRESH_RATE"
        continue
    fi
    
    cursor_y=$(echo "$cursor_data" | cut -d',' -f2 | tr -d ' ')
    cursor_y_relative=$((cursor_y - MONITOR_Y_OFFSET))
    
    # Check if Waybar is running
    if pgrep -x "waybar" >/dev/null; then
        current_state="shown"
    else
        current_state="hidden"
    fi
    
    # Determine if we should show Waybar
    if [ "$cursor_y_relative" -ge 0 ] && [ "$cursor_y_relative" -le "$HIDE_THRESHOLD" ]; then
        should_show="yes"
    else
        should_show="no"
    fi
    
    # Take action if state needs to change
    if [ "$should_show" = "yes" ] && [ "$current_state" = "hidden" ]; then
        echo "SHOWING Waybar (cursor Y=$cursor_y, relative=$cursor_y_relative)"
        waybar &
        last_state="shown"
    elif [ "$should_show" = "no" ] && [ "$current_state" = "shown" ]; then
        echo "HIDING Waybar (cursor Y=$cursor_y, relative=$cursor_y_relative)"
        pkill waybar
        last_state="hidden"
    fi
    
    sleep "$REFRESH_RATE"
done