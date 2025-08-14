#!/bin/bash

STATUS_FILE="/tmp/media/memory.polybar"

BIG_FONT=%{T7}
NORMAL_FONT=%{T1}

THRESH=("3.0" "7.0" "16")
COLOR=("#a6e3a1" "#fab387" "#f38ba8")

GLYPH_SEPERATOR=%{O8}
UNIT=%{O1}g
GLYPH="󰍛"

TEXT_COLOR="%{F#a6e3a1}"
declare glyph_color

declare OUTPUT

usage=$(free -h | grep "Mem" | awk '{print $3}' | grep -Po "[0-9.]{1,}")

for i in ${!THRESH[@]}; do
    if (( $(echo "${usage} <= ${THRESH[$i]}" | bc -l) )); then
        glyph_color="%{F${COLOR[$i]}}"
        break
    fi
done

OUTPUT+=${BIG_FONT}${glyph_color}
OUTPUT+=${GLYPH}
OUTPUT+=${GLYPH_SEPERATOR}
OUTPUT+=${NORMAL_FONT}${TEXT_COLOR}

format=0

while [[ ${#@} -gt 0 ]]; do
    case ${1} in 
        
        toggle)  
            format=$(cat ${STATUS_FILE} | grep -Po "[0-9]")
            format=$(( (${format}+1) % 2))
            ;;
            
        update)  
            format=$(cat ${STATUS_FILE} | grep -Po "[0-9]")
            ;;

        --format)
            shift
            format=${1}
            ;;

        *)
            echo "Unkown Argument: ${1}" 
            exit 1
            ;;
    esac
    echo "format=${format}" > ${STATUS_FILE}
    shift 
done


case "${format}" in
    
    0)
        OUTPUT+=${usage}
        OUTPUT+=${UNIT}
    ;;
    
    1)
        total=$(free -h | grep "Mem" | awk '{print $2}' | grep -Po "[0-9.]{1,}")
        OUTPUT+=${usage}/${total}
        OUTPUT+=${UNIT}
    ;;

    *) 
        echo "Invalid Format: ${format}" 
        exit 1
        ;;
    
esac

printf '%s\n' "${OUTPUT}"

echo "format=${format}" > ${STATUS_FILE}
