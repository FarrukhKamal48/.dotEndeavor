#!/bin/bash

window_props=$(i3-msg -t get_tree | jq '.. | select(.focused? and .focused).window_properties')
class=$(echo $window_props | jq -r '.class')

case $1 in
    
    format)
    title=$(echo $window_props | jq -r '.title')
    printf '%s: %s\n' "${class}" "${title}"
    ;;

    format-alt)
    printf '%s\n' "${class}"
    ;;
    
esac

