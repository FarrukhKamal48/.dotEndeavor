#!/bin/bash

while true; do
    for t in /sys/class/thermal/thermal_zone*; do 
        printf '%s: %s : %s\n' "$t" "$(cat $t/type)" "$(cat $t/temp)"; 
    done
    sleep 0.25s
    clear
done
