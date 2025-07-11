#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

# Launch bars
echo "---" | tee -a /tmp/polybar-mainbar.log 
polybar mainbar 2>&1 | tee -a /tmp/polybar-mainbar.log & disown

echo "Bars launched..."

sleep 0.5s
polybar-msg action "#volume-icon.hook.0"
polybar-msg action "#brightness-icon.hook.0"
polybar-msg action "#brightness.hook.0"
polybar-msg action "#volume.hook.0"
polybar-msg action "#internet-alt.module_toggle"
