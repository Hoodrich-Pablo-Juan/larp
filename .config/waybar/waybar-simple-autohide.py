#!/usr/bin/env python3
"""
Simple Waybar autohide script based on cursor position.
Hides Waybar when cursor is not near the top of the screen,
shows it when cursor approaches the top edge.
"""

import subprocess
import time
import signal
import sys
import json

# Configuration
REFRESH_RATE = 0.1  # seconds
HIDE_THRESHOLD = 50  # pixels from top to show bar
BAR_HEIGHT = 30  # Waybar height in pixels
WAYBAR_PROCNAME = "waybar"

class WaybarState:
    VISIBLE = 1
    HIDDEN = 0

def get_cursor_position():
    """Get current cursor position using hyprctl"""
    try:
        output = subprocess.check_output(["hyprctl", "cursorpos"]).decode()
        pos_x, pos_y = output.strip().split(",")
        return abs(int(pos_x.strip())), abs(int(pos_y.strip()))
    except Exception as e:
        print(f"Error getting cursor position: {e}", file=sys.stderr)
        return 0, 0

def get_waybar_pid():
    """Get Waybar PID"""
    try:
        result = subprocess.run(["pidof", WAYBAR_PROCNAME], 
                              capture_output=True, text=True)
        if result.stdout.strip():
            return int(result.stdout.strip().split()[0])
    except Exception as e:
        print(f"Error getting Waybar PID: {e}", file=sys.stderr)
    return None

def toggle_waybar_visibility(pid, show=True):
    """Toggle Waybar visibility using SIGUSR1"""
    if not pid:
        return
    try:
        # SIGUSR1 toggles Waybar visibility
        os.kill(pid, signal.SIGUSR1)
    except Exception as e:
        print(f"Error toggling Waybar visibility: {e}", file=sys.stderr)

def should_show_waybar(cursor_y):
    """Determine if Waybar should be shown based on cursor position"""
    return cursor_y <= HIDE_THRESHOLD

def main():
    print("Starting Waybar autohide script...")
    print(f"Configuration: threshold={HIDE_THRESHOLD}px, refresh={REFRESH_RATE}s")
    
    waybar_pid = get_waybar_pid()
    if not waybar_pid:
        print("Waybar process not found. Exiting.", file=sys.stderr)
        sys.exit(1)
    
    print(f"Found Waybar PID: {waybar_pid}")
    
    current_state = WaybarState.VISIBLE
    last_state = current_state
    
    try:
        while True:
            # Get cursor position
            cursor_x, cursor_y = get_cursor_position()
            
            # Determine desired state
            if should_show_waybar(cursor_y):
                current_state = WaybarState.VISIBLE
            else:
                current_state = WaybarState.HIDDEN
            
            # Toggle if state changed
            if current_state != last_state:
                toggle_waybar_visibility(waybar_pid)
                last_state = current_state
                status = "SHOWING" if current_state == WaybarState.VISIBLE else "HIDING"
                print(f"Cursor at ({cursor_x}, {cursor_y}) - {status} Waybar")
            
            time.sleep(REFRESH_RATE)
            
    except KeyboardInterrupt:
        print("\nScript stopped by user")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    import os
    main()