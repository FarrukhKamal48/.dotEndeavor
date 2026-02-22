#!/bin/bash

# Ensure jq is installed
if ! command -v jq > /dev/null 2>&1; then
    echo "jq is not installed. Please install it to use this script."
    echo "e.g., sudo apt install jq  OR  sudo dnf install jq"
    exit 1
fi

# Get the JSON tree of windows from sway
tree=$(niri msg -j windows)

# Find the PID of the focused foot window
# We look for a "con" (container) or "floating_con" that is focused
# and has an app_id of "foot" (case-insensitive)
# Note: foot's app_id is typically "foot" or "alacritty".
# We use `test("foot"; "i")` for a case-insensitive match.
focused_foot_pid=$(echo "$tree" | \
    jq '.[ ] | select(.app_id == "Alacritty" and .is_focused == true) | .pid')
echo $focused_foot_pid
# Alternative check if app_id is not found (e.g. XWayland title might be used by some older configs)
# if [ -z "$focused_foot_pid" ]; then
#     focused_foot_pid=$(echo "$tree" | \
#     jq -r '.. | select(.type? == "con" or .type? == "floating_con") | select(.focused == true) | select(.window_properties?.class? | test("foot"; "i")) | .pid')
# fi


if [ -z "$focused_foot_pid" ]; then
    echo "Focused window is not an Alacritty terminal, or its PID could not be determined."
    # As a fallback, open foot in the home directory or current dir of this script
    # foot &
    exit 1
fi

child_pid=$(pgrep -P $focused_foot_pid)

# Get the current working directory of that PID
target_cwd=$(readlink -f "/proc/${child_pid}/cwd")

if [ -z "$target_cwd" ] || [ ! -d "$target_cwd" ]; then
    echo "Could not determine the working directory for Alacritty PID ${focused_foot_pid}."
    echo "Path found: '${target_cwd}'"
    # Fallback if CWD cannot be read
    # foot &
    exit 1
fi

# Open a new foot window in the determined CWD
echo "Opening new foot in: ${target_cwd}"
alacritty -e yazi "$target_cwd" &

# Optional: Bring the new window to focus (might require slight delay)
# sleep 0.1 # Adjust if needed
# swaymsg "[app_id=foot] focus" # This might focus the *last* opened, good enough usually

exit 0
