#!/usr/bin/env bash

if (( ! $(killall -v -q polybar | grep -c "Killed") )); then
    killall -s KILL polybar
fi

echo "---" | tee -a /tmp/polybar-mainbar.log 
polybar mainbar 2>&1 | tee -a /tmp/polybar-mainbar.log & disown

echo "Bars launched..."
