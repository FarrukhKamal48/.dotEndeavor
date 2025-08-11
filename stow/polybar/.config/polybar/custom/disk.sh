#!/bin/bash

BIG_FONT=%{T7}
NORMAL_FONT=%{T1}

GLYPH_SEPERATOR=%{O5}
MOUNT_SEPERATOR=%{O10}

declare -A MOUNTS
MOUNTS["/mnt/HomeWork"]="󰑹"
MOUNTS["/"]="󰆼"

declare OUTPUT

UNIT="%{O1}g"

for mount in "${!MOUNTS[@]}"; do
    glyph=${MOUNTS[$mount]}
    usage=$(df -h ${mount} | awk '{print $4}' | grep -Po '[0-9]{1,}')

    OUTPUT+=${MOUNT_SEPERATOR}
    OUTPUT+=${BIG_FONT}
    OUTPUT+=${glyph}
    OUTPUT+=${GLYPH_SEPERATOR}
    OUTPUT+=${NORMAL_FONT}
    
    case $1 in
        format)
            OUTPUT+=${usage}
            OUTPUT+=${UNIT}
        ;;
        
        format-alt)
            total=$(df -h ${mount} | awk '{print $2}' | grep -Po '[0-9]{1,}')
            OUTPUT+=${usage}/${total}
            OUTPUT+=${UNIT}
        ;;
    esac
done

printf '%s\n' "${OUTPUT}"

