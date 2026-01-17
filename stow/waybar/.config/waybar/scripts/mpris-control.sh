#!/bin/bash

# A file to store the name of the player we want to control
CONTROL_STATE_FILE="/tmp/waybar_mpris_controlled_player"

# Get a list of all available players
players=($(playerctl -l 2>/dev/null))

# If no players are running, clear the state and exit
if [ ${#players[@]} -eq 0 ]; then
    > "$CONTROL_STATE_FILE"
    exit
fi

# Get the currently controlled player from the state file
current_player=$(cat "$CONTROL_STATE_FILE" 2>/dev/null)

# If the state file is empty or the player isn't running, pick the first one
if [ -z "$current_player" ] || ! playerctl -l 2>/dev/null | grep -q "^$current_player$"; then
    current_player="${players[0]}"
fi

# Find the index of the current player in the list
current_index=-1
for i in "${!players[@]}"; do
    if [[ "${players[$i]}" == "$current_player" ]]; then
        current_index=$i
        break
    fi
done

# Calculate the index of the next player, wrapping around
next_index=$(( (current_index + 1) % ${#players[@]} ))
new_player="${players[$next_index]}"

# Save the new player's name to the state file
echo "$new_player" > "$CONTROL_STATE_FILE"

# *** THIS IS THE KEY TO UPDATING THE DISPLAY ***
# We "poke" the new player to make it the active one for playerctld.
# Waybar's mpris module (using default settings) listens to playerctld.
playerctl --player=$new_player status >/dev/null

# Optional: Send a notification to confirm the switch
notify-send "Media Control" "Switched to ${new_player}" -a "Waybar" -u low -i "multimedia-player"
