#!/usr/bin/env python3
"""
Simple Waybar autohide script using Hyprland window rules.
Hides Waybar when cursor is not near the top of the screen,
shows it when cursor approaches the top edge.
"""

import subprocess
import time
import sys

# Configuration
REFRESH_RATE = 0.1  # seconds
HIDE_THRESHOLD = 50  # pixels from top to show bar
WAYBAR_TITLE = "waybar"

def get_cursor_position():
    """Get current cursor position using hyprctl"""
    try:
        output = subprocess.check_output(["hyprctl", "cursorpos"]).decode()
        pos_x, pos_y = output.strip().split(",")
        return abs(int(pos_x.strip())), abs(int(pos_y.strip()))
    except Exception as e:
        print(f"Error getting cursor position: {e}", file=sys.stderr)
        return 0, 0

def set_waybar_visibility(visible):
    """Show or hide Waybar using Hyprland window rules"""
    try:
        if visible:
            # Show Waybar
            subprocess.run(["hyprctl", "keyword", "windowrule", f"title:{WAYBAR_TITLE}", "move", "0", "0"], check=False)
            subprocess.run(["hyprctl", "keyword", "windowrule", f"title:{WAYBAR_TITLE}", "size", "1920", "30"], check=False)
        else:
            # Hide Waybar by moving it off-screen
            subprocess.run(["hyprctl", "keyword", "windowrule", f"title:{WAYBAR_TITLE}", "move", "-2000", "0"], check=False)
    except Exception as e:
        print(f"Error setting Waybar visibility: {e}", file=sys.stderr)

def should_show_waybar(cursor_y):
    """Determine if Waybar should be shown based on cursor position"""
    return cursor_y <= HIDE_THRESHOLD

def main():
    print("Starting Waybar autohide script (Hyprland version)...")
    print(f"Configuration: threshold={HIDE_THRESHOLD}px, refresh={REFRESH_RATE}s")
    
    current_state = True  # Start with Waybar visible
    last_state = current_state
    
    try:
        while True:
            # Get cursor position
            cursor_x, cursor_y = get_cursor_position()
            
            # Determine desired state
            current_state = should_show_waybar(cursor_y)
            
            # Toggle if state changed
            if current_state != last_state:
                set_waybar_visibility(current_state)
                last_state = current_state
                status = "SHOWING" if current_state else "HIDING"
                print(f"Cursor at ({cursor_x}, {cursor_y}) - {status} Waybar")
            
            time.sleep(REFRESH_RATE)
            
    except KeyboardInterrupt:
        print("\nScript stopped by user")
        # Make sure Waybar is visible when script exits
        set_waybar_visibility(True)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        # Make sure Waybar is visible when script exits
        set_waybar_visibility(True)
        sys.exit(1)

if __name__ == "__main__":
    main()