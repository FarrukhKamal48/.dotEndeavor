#!/bin/bash

format=0
STATUS_FILE="/mnt/media/disk.polybar"

if [[ ! -s ${STATUS_FILE} ]]; then
    echo "format=${format}" > ${STATUS_FILE}
fi

BIG_FONT=%{T7}
NORMAL_FONT=%{T1}

GLYPH_SEPERATOR=%{O5}
MOUNT_SEPERATOR=${ALERT_COLOR}%{O7}%{T11}▍%{T1}

declare -A MOUNTS
MOUNTS["/mnt/HomeWork"]="󰑹"
MOUNTS["/"]="󰆼"

declare OUTPUT

UNIT="%{O1}g"

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


for mount in "${!MOUNTS[@]}"; do
    glyph=${MOUNTS[$mount]}
    usage=$(df -h ${mount} | awk '{print $4}' | grep -Po '[0-9]{1,}')

    OUTPUT+=${BIG_FONT}
    OUTPUT+=${glyph}
    OUTPUT+=${GLYPH_SEPERATOR}
    OUTPUT+=${NORMAL_FONT}

    case ${format} in
        
        0)
            OUTPUT+=${usage}
            OUTPUT+=${UNIT}
        ;;
        
        1)
            total=$(df -h ${mount} | awk '{print $2}' | grep -Po '[0-9]{1,}')
            OUTPUT+=${usage}/${total}
            OUTPUT+=${UNIT}
        ;;

        *) 
            echo "Invalid format '${format}'" 
            exit 1
            ;;
        
    esac
    
    OUTPUT+=${MOUNT_SEPERATOR}
done

# remove the extra sperator from the end
OUTPUT=${OUTPUT%${MOUNT_SEPERATOR}}

printf '%s\n' "${OUTPUT}"

echo "format=${format}" > ${STATUS_FILE}

