
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
        glyph_color="%{F${COLOR[$i]}}"
        break
    fi
done

OUTPUT+=${BIG_FONT}${glyph_color}
OUTPUT+=${GLYPH}
OUTPUT+=${GLYPH_SEPERATOR}
OUTPUT+=${NORMAL_FONT}${TEXT_COLOR}

case $1 in
    
    format)
        OUTPUT+=${usage}
        OUTPUT+=${UNIT}
    ;;
    
    format-alt)
        total=$(free -h | grep "Mem" | awk '{print $2}' | grep -Po "[0-9.]{1,}")
        OUTPUT+=${usage}/${total}
        OUTPUT+=${UNIT}
    ;;
    
esac

printf '%s\n' "${OUTPUT}"

