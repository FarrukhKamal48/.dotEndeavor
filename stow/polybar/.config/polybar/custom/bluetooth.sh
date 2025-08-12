#!/bin/bash

BIG_FONT=%{T7}
NORMAL_FONT=%{T1}
ALERT_COLOR=%{F#eba0ac}
NORMAL_COLOR=%{F#89dceb}

FORMAT_GLYPH=${BIG_FONT}${ALERT_COLOR}
FORMAT_TEXT_OFF=${NORMAL_FONT}${ALERT_COLOR}
FORMAT_TEXT_ON=${NORMAL_FONT}${NORMAL_COLOR}

GLYPH_SEPERATOR=%{O5}
DEVICE_SEPERATOR=%{O10}

POWER_OFF_GLYPH="󰂲"
POWER_ON_GLYPH="󰂯"

declare -A devices
devices["84:AC:60:31:89:58"]="󰋋 PEATS"

declare OUTPUT

declare -A args
args["format"]=0
args["compact"]=0
args["smart"]=0

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

        compact)    args["compact"]=1 ;;
        smart)      args["smart"]=1 ;;
        format)     args["format"]=1 ;;
        format-alt) args["format"]=2 ;;
        
        *) echo "Unkown Argument: ${1}" ;;
    esac
    
    shift
done

case ${args["format"]} in
    
    1)
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

        connected_n=0
        for dev_adr in ${!devices[@]}; do
            dev_info=$(bluetoothctl info ${dev_adr})
            connected=$(echo ${dev_info} | grep -c "Connected: yes")

            dev_texts=(${devices["${dev_adr}"]})

            OUTPUT+=${DEVICE_SEPERATOR}
            OUTPUT+=${FORMAT_GLYPH}

            # add glyph for device
            OUTPUT+=${dev_texts[0]}
            unset dev_texts[0]

            # add device name
            OUTPUT+=${GLYPH_SEPERATOR}
            OUTPUT+=${GLYPH_SEPERATOR}
            
            if (( ${connected} )); then
                connected_n=$((${connected_n}+1))
                OUTPUT+=${FORMAT_TEXT_ON}
                OUTPUT+="${dev_texts[@]}"
            else
                OUTPUT+=${FORMAT_TEXT_OFF}
                OUTPUT+="OFF"
            fi
            
        done

        if (( ${args["smart"]} == 0 )); then
            printf '%s\n' "${CONTROLLER}${OUTPUT}"
            exit 0
        fi

        if [[ ${connected_n} -gt 0 ]]; then
            printf '%s\n' "${OUTPUT#${DEVICE_SEPERATOR}}"
        else
            printf '%s\n' "${CONTROLLER}"
        fi
        
    ;;

esac

