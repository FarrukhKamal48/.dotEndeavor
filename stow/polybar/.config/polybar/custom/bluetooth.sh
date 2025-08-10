#!/bin/bash

GLYPH_FONT=%{T7}
TEXT_FONT=%{T1}
GLYPH_COLOR=%{F#eba0ac}
TEXT_COLOR=%{F#89dceb}

POWER_OFF_GLYPH="󰂲"
POWER_ON_GLYPH="󰂯"

GLYPH_SEPERATOR=%{O5}
DEVICE_SEPERATOR=%{O10}

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
        case $2 in
            "compact")  COMPACT=1 ;;
            * )         COMPACT=0 ;;
        esac

        OUTPUT=${GLYPH_FONT}${GLYPH_COLOR}
        
        # bluetooth controller status
        if (( ${POWERED} )); then
            OUTPUT+=${POWER_ON_GLYPH}
            OUTPUT+=${GLYPH_SEPERATOR}
            OUTPUT+=${TEXT_FONT}${TEXT_COLOR}
            OUTPUT+="ON" 
        else
            OUTPUT+=${POWER_OFF_GLYPH}
            OUTPUT+=${GLYPH_SEPERATOR}
            OUTPUT+=${TEXT_FONT}${GLYPH_COLOR}
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
            OUTPUT+=${GLYPH_FONT}${GLYPH_COLOR}

            # add glyph for device
            OUTPUT+=${dev_texts[0]}
            unset dev_texts[0]

            # add device name
            OUTPUT+=${TEXT_FONT}
            OUTPUT+=${GLYPH_SEPERATOR}
            OUTPUT+=${GLYPH_SEPERATOR}
            
            if (( ${connected} )); then
                OUTPUT+=${TEXT_COLOR}
                OUTPUT+="${dev_texts[@]}"
            else
                OUTPUT+="OFF"
            fi
            
        done
        
        printf '%s\n' "${OUTPUT}"
    ;;

esac

