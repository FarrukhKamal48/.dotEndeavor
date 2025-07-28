#!/bin/bash

declare -A mnt_points
mnt_points["/mnt/HomeWork"]="%{T5}󰑹"
mnt_points["/"]="%{T5}󰆼"

declare out

unit="%{O1}g"

for mount in "${!mnt_points[@]}"; do
    glyph=${mnt_points[$mount]}
    usage=$(df -h ${mount} | awk '{print $4}' | tail -n 1 | sed 's/G//')

    case $1 in
        
        format)
        out+=("${glyph}%{T1} ${usage}${unit}")
        ;;
        
        format-alt)
        total=$(df -h ${mount} | awk '{print $2}' | tail -n 1 | sed 's/G//')

        out+=("${glyph}%{T1} ${usage}/${total}${unit}")
        ;;
        
    esac
done

echo ${out[@]}

