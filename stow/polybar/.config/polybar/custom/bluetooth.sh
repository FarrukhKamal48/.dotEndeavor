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

POWERED=$(bluetoothctl show | grep -c "Powered: yes")

case $1 in
    
    power_toggle)
        if (( ${POWERED} )); then
            ~/.scripts/tools/bluetooth.sh power_off
        else
            ~/.scripts/tools/bluetooth.sh power_on
        fi
        ;;

    format)
        COMPACT=$(echo ${2} | grep -c "compact")

        OUTPUT=${FORMAT_GLYPH}
        
        # bluetooth controller status
        if (( ${POWERED} )); then
            OUTPUT+=${POWER_ON_GLYPH}
            OUTPUT+=${GLYPH_SEPERATOR}
            OUTPUT+=${FORMAT_TEXT_ON}
            OUTPUT+="ON" 
        else
            OUTPUT+=${POWER_OFF_GLYPH}
            OUTPUT+=${GLYPH_SEPERATOR}
            OUTPUT+=${FORMAT_TEXT_OFF}
            OUTPUT+="OFF" 
            
            if (( ${COMPACT} )); then
                printf '%s\n' "${OUTPUT}"
                exit 0
            fi
        fi

        # bluetooth devices
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
                OUTPUT+=${FORMAT_TEXT_ON}
                OUTPUT+="${dev_texts[@]}"
            else
                OUTPUT+=${FORMAT_TEXT_OFF}
                OUTPUT+="OFF"
            fi
            
        done
        
        printf '%s\n' "${OUTPUT}"
    ;;

esac

