
#!/bin/bash

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
        color="%{F${COLOR[$i]}}"
        break
    fi
done

OUTPUT+=${BIG_FONT}${color}
OUTPUT+=${GLYPH}
OUTPUT+=${GLYPH_SEPERATOR}
OUTPUT+=${NORMAL_FONT}${TEXT_COLOR}

case $1 in
    
    format)
        OUTPUT+=${usage}
        OUTPUT+=${UNIT}
    ;;
    
    format-alt)
        total=$(free -h | awk '{print $2}' | head -n 2 | tail -n 1 | sed 's/Gi//')
        OUTPUT+=${usage}/${total}
        OUTPUT+=${UNIT}
    ;;
    
esac

printf '%s\n' "${OUTPUT}"

