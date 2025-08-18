#!/bin/bash

format=0
STATUS_FILE="/mnt/media/gpu.polybar"
FORMAT_COUNT=2

if [[ ! -s ${STATUS_FILE} ]]; then
    echo "format=${format}" > ${STATUS_FILE}
fi

BIG_FONT=%{T5}
NORMAL_FONT=%{T1}

GLYPH_SEPERATOR=%{O5}
SECTION_SEPERATOR=${ALERT_COLOR}%{O7}%{T11}▍%{T1}

GPU_USAGE_GLYPH="󰢮${NORMAL_FONT}%{O4}"
GPU_TEMP_GLYPH=""
GPU_MEMORY_GLYPH="󰝤%{O3}"

declare OUTPUT

PERCENT_UNIT="%{O1}%"
TEMP_UNIT="%{O1}C"
VRAM_UNIT="%{O1}m"

while [[ ${#@} -gt 0 ]]; do
    case ${1} in 
        
        toggle)  
            format=$(cat ${STATUS_FILE} | grep -Po "[0-9]")
            format=$(( (${format}+1) % ${FORMAT_COUNT}))
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

smi_query=$(nvidia-smi -q -d TEMPERATURE,UTILIZATION,MEMORY)
gpu_temp=$(echo "${smi_query}" | grep -E "Temprature|GPU Current Temp" | awk '{print $5}')
gpu_usage=$(echo "${smi_query}" | grep "GPU.*:.*%" | awk '{print $3}')
vram_usage=$(echo "${smi_query}" | grep "Used" | awk '{print $3}' | head -1)

case ${format} in 
    0)
        OUTPUT+=${BIG_FONT}${GPU_TEMP_GLYPH}${NORMAL_FONT}
        OUTPUT+=${GLYPH_SEPERATOR}
        OUTPUT+=${gpu_temp}${TEMP_UNIT}
        
        OUTPUT+=${SECTION_SEPERATOR}
        
        OUTPUT+=${BIG_FONT}${GPU_USAGE_GLYPH}${NORMAL_FONT}
        OUTPUT+=${GLYPH_SEPERATOR}
        OUTPUT+=${gpu_usage}${PERCENT_UNIT}
        ;;
        
    1)
        OUTPUT+=${BIG_FONT}${GPU_TEMP_GLYPH}${NORMAL_FONT}
        OUTPUT+=${GLYPH_SEPERATOR}
        OUTPUT+=${gpu_temp}${TEMP_UNIT}
        
        OUTPUT+=${SECTION_SEPERATOR}
        
        OUTPUT+=${BIG_FONT}${GPU_USAGE_GLYPH}${NORMAL_FONT}
        OUTPUT+=${GLYPH_SEPERATOR}
        OUTPUT+=${gpu_usage}${PERCENT_UNIT}
        
        OUTPUT+=${SECTION_SEPERATOR}
        
        OUTPUT+=${BIG_FONT}${GPU_MEMORY_GLYPH}${NORMAL_FONT}
        OUTPUT+=${GLYPH_SEPERATOR}
        OUTPUT+=${vram_usage}${VRAM_UNIT}
        ;;

    *)
        echo "Invalid format '${format}'" 
        exit 1
        ;;
esac

printf '%s\n' ${OUTPUT}

echo "format=${format}" > ${STATUS_FILE}
