#!/bin/bash

declare -A args
args["format"]=0
args["compact"]=0
args["smart"]=1
STATUS_FILE="/mnt/media/bluetooth.polybar"
FORMAT_COUNT=2

if [[ ! -s ${STATUS_FILE} ]]; then
    echo "format=${args["format"]}" > ${STATUS_FILE}
fi

BIG_FONT=%{T7}
NORMAL_FONT=%{T1}
ALERT_COLOR=%{F#eba0ac}
NORMAL_COLOR=%{F#89dceb}

FORMAT_GLYPH=${BIG_FONT}${ALERT_COLOR}
FORMAT_TEXT_OFF=${NORMAL_FONT}${ALERT_COLOR}
FORMAT_TEXT_ON=${NORMAL_FONT}${NORMAL_COLOR}

GLYPH_SEPERATOR=%{O5}
DEVICE_SEPERATOR=%{O7}
BAR_SEPERATOR=${ALERT_COLOR}%{O7}%{T11}▍%{T1} 

POWER_OFF_GLYPH="󰂲"
POWER_ON_GLYPH="󰂯"

PERCENT_UNIT="%{O1}%"

declare -A devices
devices["84:AC:60:31:89:58"]="󰋋 PEATS"

declare OUTPUT

powered=$(bluetoothctl show | grep -c "Powered: yes")

while [[ ${#@} -gt 0 ]]; do
    case ${1} in 
        power_toggle)
            if (( ${powered} )); then
                ~/.scripts/tools/bluetooth.sh power_off
            else
                ~/.scripts/tools/bluetooth.sh power_on
            fi
            powered=$(bluetoothctl show | grep -c "Powered: yes")
            ;;

        --compact|-c)    
            shift
            args["compact"]=${1} 
            ;;
            
        --smart|-s)      
            shift
            args["smart"]=${1} 
            ;;
            
        --format|-f)     
            shift
            args["format"]=${1} 
            echo "format=${args["format"]}" > ${STATUS_FILE}
            ;;
        
        *) 
            echo "Unkown Argument: ${1}" 
            exit 1
            ;;
        
    esac
    
    shift
done

case ${args["format"]} in
    
    0)
        CONTROLLER=${FORMAT_GLYPH}
        
        # bluetooth controller status
        if (( ${powered} )); then
            CONTROLLER+=${POWER_ON_GLYPH}
            CONTROLLER+=${GLYPH_SEPERATOR}
            CONTROLLER+=${FORMAT_TEXT_ON}
            CONTROLLER+="ON" 
        else
            CONTROLLER+=${POWER_OFF_GLYPH}
            CONTROLLER+=${GLYPH_SEPERATOR}
            CONTROLLER+=${FORMAT_TEXT_OFF}
            CONTROLLER+="OFF" 
            
            if (( ${args["compact"]} )); then
                printf '%s\n' "${CONTROLLER}"
                exit 0
            fi
        fi

        device_connected=0
        for dev_adr in ${!devices[@]}; do
            dev_info="$(bluetoothctl info ${dev_adr})"
            connected=$(echo "${dev_info}" | grep -c "Connected: yes")

            dev_texts=(${devices["${dev_adr}"]})

            OUTPUT+=${FORMAT_GLYPH}

            # add glyph for device
            OUTPUT+=${dev_texts[0]}
            unset dev_texts[0]

            # add device name
            OUTPUT+=${GLYPH_SEPERATOR}
            OUTPUT+=${GLYPH_SEPERATOR}
            
            if (( ${connected} )); then
                device_connected=1
                OUTPUT+=${FORMAT_TEXT_ON}
                OUTPUT+="${dev_texts[@]}"

                battery=$(echo "${dev_info}" | grep "Battery Percentage" | grep -Po "[0-9]{1,3}(?=\))")
                if [[ -n ${battery} ]]; then
                    OUTPUT+=${GLYPH_SEPERATOR}
                    OUTPUT+=${battery}${PERCENT_UNIT}
                fi
            else
                OUTPUT+=${FORMAT_TEXT_OFF}
                OUTPUT+="OFF"
            fi
            
            OUTPUT+=${DEVICE_SEPERATOR}
        done

        OUTPUT=${OUTPUT%${DEVICE_SEPERATOR}}

        if (( ${args["smart"]} == 0 )); then
            printf '%s\n' "${CONTROLLER}${BAR_SEPERATOR}${OUTPUT}"
        else
            if (( ${device_connected} )); then
                printf '%s\n' "${OUTPUT}"
            else
                printf '%s\n' "${CONTROLLER}"
            fi
        fi
            
        ;;
    
    *) 
        echo "Invalid Format: ${args["format"]}" 
        exit 1
        ;;
    
esac

