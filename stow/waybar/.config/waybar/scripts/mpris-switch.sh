#!/bin/bash

# A file to store the name of the currently selected player
STATE_FILE="/tmp/waybar_mpris_player"

# Get a list of all available players
players=($(playerctl -l))

if [ ${#players[@]} -eq 0 ]; then
    # No players running, clear the state and exit
    > "$STATE_FILE"
    exit
fi

# Get the currently selected player from the state file
current_player=$(cat "$STATE_FILE" 2>/dev/null)
current_index=-1

# Find the index of the current player in the list
for i in "${!players[@]}"; do
    if [[ "${players[$i]}" == "$current_player" ]]; then
        current_index=$i
        break
    fi
done

# Calculate the index of the next player
next_index=$(( (current_index + 1) % ${#players[@]} ))
new_player="${players[$next_index]}"

# Save the new player's name to the state file
echo "$new_player" > "$STATE_FILE"

# Optional: Send a notification to see which player is now active
notify-send "Media Control" "Switched to ${new_player}" -a "Waybar" -u low -i "multimedia-player"
