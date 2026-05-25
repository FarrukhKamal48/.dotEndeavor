#!/bin/bash
# Kill tmux sessions that have been unattached for more than 10 minutes

now=$(date +%s)
max_age=600

tmux list-sessions -F "#{session_name}:#{session_last_attached}" -f "#{==:#{session_attached},0}" | while IFS=: read -r session last_attached; do
    if [ -n "$last_attached" ]; then
        age=$((now - last_attached))
        if [ $age -gt $max_age ]; then
            echo "Killing session $session (unattached for ${age}s)"
            tmux kill-session -t "$session"
        fi
    fi
done
