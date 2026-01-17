#!/bin/bash

# The same state file used by the switcher script
STATE_FILE="/tmp/waybar_mpris_player"

# Function to print the Waybar module output
print_waybar_output() {
    # Get the name of the player we should be controlling
    player=$(cat "$STATE_FILE" 2>/dev/null)

    # If no player is selected or the selected player is not running, show nothing
    if ! playerctl -l | grep -q "$player"; then
        echo '{"text": "", "tooltip": "No player active"}'
        return
    fi

    # Get metadata and status from the active player
    # Using --follow ensures this script blocks and waits for updates
    playerctl --player=$player --follow metadata --format \
        '{"text": "{{status_icon}} {{artist}} - {{title}}", "tooltip": "{{playerName}}: {{title}}\nby {{artist}}", "class": "{{status}}"}' 2>/dev/null
}

# This is the main loop.
# It will run the print_waybar_output function once immediately,
# and then it will re-run it every time the state file is changed.
while true; do
    print_waybar_output
    # The 'inotifywait' command waits for the state file to be modified (e.g., by the switch script)
    # This is more efficient than looping every second.
    inotifywait -e modify "$STATE_FILE" >/dev/null 2>&1
done
