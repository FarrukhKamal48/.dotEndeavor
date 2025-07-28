#!/bin/bash

thresh=("3.0" "7.0" "16")
colors=( "#a6e3a1" "#f9e2af" "#f38ba8")
text_color="%{F#a6e3a1}"

glyph="%{T5}󰍛"
unit="%{O1}g"
used=$(free -h | awk '{print $3}' | head -n 2 | tail -n 1 | sed 's/Gi//')

for i in ${!thresh[@]}; do
    if (( $(echo "${used} < ${thresh[$i]}" | bc -l) )); then
        color="%{F${colors[$i]}}"
        break
    fi
done


case $1 in
    
    format)
    printf '%s\n' "${color}${glyph}%{T1} ${text_color}${used}${unit}" 
    ;;
    
    format-alt)
    total=$(free -h | awk '{print $2}' | head -n 2 | tail -n 1 | sed 's/Gi//')
    printf '%s\n' "${color}${glyph}%{T1} ${text_color}${used}/${total}${unit}" 
    ;;
    
esac

