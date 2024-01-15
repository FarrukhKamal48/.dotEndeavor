#!/bin/bash

orientation=$(xrandr --query --verbose | grep "eDP-1" | cut -d ' ' -f 6)

if [[ "$orientation" = "normal" ]]; then
    xrandr -o left
elif [[ "$orientation" = "left" ]]; then
    xrandr -o right
elif [[ "$orientation" = "right" ]]; then
    xrandr -o normal
fi


