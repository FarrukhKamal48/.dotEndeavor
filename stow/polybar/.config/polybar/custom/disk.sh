#!/bin/bash

declare -A mnt_points
mnt_points["/mnt/HomeWork"]="%{T5}󰑹"
mnt_points["/"]="%{T5}󰆼"

declare out

for mount in "${!mnt_points[@]}"; do
    glyph=${mnt_points[$mount]}
    usage=$(df -h ${mount} | awk '{print $4}' | tail -n 1)

    out+=("${glyph}%{T1} ${usage}")
done

echo ${out[@]}

