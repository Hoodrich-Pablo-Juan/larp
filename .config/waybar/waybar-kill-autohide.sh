#!/bin/bash

# Simple Waybar autohide script
# Kills Waybar to hide it, launches it when cursor is near top

# Configuration
HIDE_THRESHOLD=50  # pixels from top to show bar
REFRESH_RATE=0.1   # seconds between checks
MAX_ITERATIONS=1000 # safety limit
WAYBAR_CMD="waybar"
MONITOR_Y_OFFSET=1440  # Vertical offset of your monitor

echo "Starting Waybar autohide script (kill/launch version)"
echo "Move cursor within $HIDE_THRESHOLD pixels of top to show Waybar"
echo "Press Ctrl+C to stop"
echo

# Make sure Waybar is running initially
if ! pgrep -x "$WAYBAR_CMD" >/dev/null; then
    echo "Starting Waybar..."
    $WAYBAR_CMD &
    sleep 2
fi

iteration=0
waybar_visible=true

while [ $iteration -lt $MAX_ITERATIONS ]; do
    iteration=$((iteration + 1))
    
    # Get cursor position
    cursor_pos=$(hyprctl cursorpos 2>/dev/null)
    if [ -z "$cursor_pos" ]; then
        echo "Error: Could not get cursor position" >&2
        break
    fi
    
    # Extract Y coordinate
    cursor_y=$(echo "$cursor_pos" | cut -d',' -f2 | tr -d ' ')
    
    # Check if Waybar is currently running
    if pgrep -x "$WAYBAR_CMD" >/dev/null; then
        current_visible=true
    else
        current_visible=false
    fi
    
    # Determine desired state (account for monitor offset)
    local cursor_y_relative=$((cursor_y - MONITOR_Y_OFFSET))
    if [ "$cursor_y_relative" -ge 0 ] && [ "$cursor_y_relative" -le "$HIDE_THRESHOLD" ]; then
        # Cursor near top - Waybar should be visible
        if [ "$current_visible" = false ]; then
            echo "Cursor at Y=$cursor_y - SHOWING Waybar"
            $WAYBAR_CMD &
            waybar_visible=true
        fi
    else
        # Cursor not near top - Waybar should be hidden
        if [ "$current_visible" = true ]; then
            echo "Cursor at Y=$cursor_y - HIDING Waybar"
            pkill "$WAYBAR_CMD"
            waybar_visible=false
        fi
    fi
    
    sleep "$REFRESH_RATE"
done

echo "Script completed after $iteration iterations"
# Make sure Waybar is visible when script exits
if ! pgrep -x "$WAYBAR_CMD" >/dev/null; then
    echo "Restoring Waybar..."
    $WAYBAR_CMD &
fi