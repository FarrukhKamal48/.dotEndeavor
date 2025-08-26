#!/bin/bash

format=0
STATUS_FILE="/mnt/media/cpu.polybar"
CPU_TIMES_LAST_FILE="/mnt/media/cpu-time-totals-last.polybar"
FORMAT_COUNT=3

if [[ ! -s ${STATUS_FILE} ]]; then
    echo "format=${format}" > ${STATUS_FILE}
fi
curr_cpu_time_info=($(cat /proc/stat | grep "cpu" | sed 's/cpu..//g'))
if [[ ! -s ${CPU_TIMES_LAST_FILE} ]]; then
    echo "${curr_cpu_time_info[@]}" > ${CPU_TIMES_LAST_FILE}
fi

BIG_FONT=%{T5}
NORMAL_FONT=%{T1}

GLYPH_SEPERATOR=%{O5}
SECTION_SEPERATOR=${ALERT_COLOR}%{O7}%{T11}▍%{T1}

CPU_USAGE_GLYPH="󰍛${NORMAL_FONT}%{O2}"
CPU_TEMP_GLYPH=""

declare OUTPUT

USAGE_UNIT="%{O1}%"
TEMP_UNIT="%{O1}C"

while [[ ${#@} -gt 0 ]]; do
    case ${1} in 
        
        --toggle|-t)  
            format=$(cat ${STATUS_FILE} | grep -Po "[0-9]")
            format=$(( (${format}+1) % ${FORMAT_COUNT}))
            ;;
            
        --update|-u) 
            format=$(cat ${STATUS_FILE} | grep -Po "[0-9]")
            ;;

        --format|-f)
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

last_cpu_time_info=($(cat ${CPU_TIMES_LAST_FILE}))

for cpu in {0..16}; do
    total_prev=0
    total_curr=0
    for col in {0..9}; do
        total_prev=$(( ${total_prev} + ${last_cpu_time_info[(( 10 * ${cpu} + ${col} ))]} ))
        total_curr=$(( ${total_curr} + ${curr_cpu_time_info[(( 10 * ${cpu} + ${col} ))]} ))
    done
    idle_diff=$(( ${curr_cpu_time_info[(( 10 * ${cpu} + 3 ))]} - ${last_cpu_time_info[(( 10 * ${cpu} + 3 ))]} ))
    total_diff=$(( ${total_curr} - ${total_prev} ))
    
    usages[${cpu}]=$(echo "scale=0; (( (${total_diff} - ${idle_diff}) * 100/${total_diff} ))" | bc -l)
done


temps=($(sensors -j \
    | jq '.[] | select(.Adapter=="ISA adapter") | .[] | select(type=="object") | to_entries[] | select(.key|test("^temp.*_input$")) | .value' \
    | xargs printf '%.0f\n'))

case ${format} in 
    0)
        OUTPUT+=${BIG_FONT}${CPU_TEMP_GLYPH}${NORMAL_FONT}
        OUTPUT+=${GLYPH_SEPERATOR}
        OUTPUT+=${temps[0]}${TEMP_UNIT}
        
        OUTPUT+=${SECTION_SEPERATOR}
        
        OUTPUT+=${BIG_FONT}${CPU_USAGE_GLYPH}${NORMAL_FONT}
        OUTPUT+=${GLYPH_SEPERATOR}
        OUTPUT+=${usages[0]}${USAGE_UNIT}
        ;;

    1|2)
        OUTPUT+=${BIG_FONT}${CPU_TEMP_GLYPH}${NORMAL_FONT}
        OUTPUT+=${GLYPH_SEPERATOR}

        OUTPUT+=${temps[0]}${GLYPH_SEPERATOR}
        unset temps[0]
        if [[ ${format} -eq 2 ]]; then
            for T in ${temps[@]}; do
                OUTPUT+=${T}${GLYPH_SEPERATOR}
            done
        fi
        OUTPUT+=${TEMP_UNIT}
        
        OUTPUT+=${SECTION_SEPERATOR}
        
        OUTPUT+=${BIG_FONT}${CPU_USAGE_GLYPH}${NORMAL_FONT}
        OUTPUT+=${GLYPH_SEPERATOR}
        
        OUTPUT+=${usages[0]}${GLYPH_SEPERATOR}
        unset usages[0]
        for U in ${usages[@]}; do
            OUTPUT+=${U}${GLYPH_SEPERATOR}
        done
        OUTPUT+=${USAGE_UNIT}
        
        ;;

    *)
        echo "Invalid format '${format}'" 
        exit 1
        ;;
esac

printf '%s\n' ${OUTPUT}

echo "format=${format}" > ${STATUS_FILE}
echo "${curr_cpu_time_info[@]}" > ${CPU_TIMES_LAST_FILE}
