#!/bin/bash
# --- Configuration ---
CACHE_DIR="$HOME/.cache/screenshots"
MAX_AGE_DAYS=7

# --- Setup ---
# Safely creates the directory; does nothing if it already exists
mkdir -p "$CACHE_DIR"

# Clean up files older than 7 days
find "$CACHE_DIR" -type f -mtime +$MAX_AGE_DAYS -delete

# --- Execution ---
# 1. Run hyprpicker in the background
hyprpicker -r -z &
hyprpicker_pid=$!

# 2. Give the picker a moment to initialize
sleep 0.1

# 3. Take the screenshot and save it automatically
FILENAME="scr_$(date +%Y%m%d_%H%M%S).png"

# We removed --clipboard-only so it actually saves to the disk
hyprshot -m region -o "$CACHE_DIR" -f "$FILENAME"

# 4. Cleanup processes
kill $hyprpicker_pid
