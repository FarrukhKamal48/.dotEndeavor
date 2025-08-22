#!/bin/bash

format=0
STATUS_FILE="/mnt/media/net.polybar"
FORMAT_COUNT=2

if [[ ! -s ${STATUS_FILE} ]]; then
    echo "format=${format}" > ${STATUS_FILE}
fi

BIG_FONT=%{T5}
NORMAL_FONT=%{T1}
ALERT_COLOR=%{F#eba0ac}
NORMAL_COLOR=%{F#89dceb}

GLYPH_SEPERATOR=%{O5}
SECTION_SEPERATOR=%{O8}

SPEED_UNIT="%{O1}k"

declare -A NETWORKS
NETWORKS["TP-Link_6E36_5G"]="TP-5G"
# NETWORKS["StormFiber-13C0"]="Storm"
NETWORKS["StormFiber-13C0-5G"]="Storm-5G"

RAMP_SIGNAL=( 󰤯 󰤟 󰤢 󰤥 󰤨 )
OFF_GLYPH=󰤮
UPLOAD_GLYPH=
DOWNLOAD_GLYPH=

POWER_OFF_FORMAT="${BIG_FONT}${OFF_GLYPH}${NORMAL_FONT}${GLYPH_SEPERATOR}LO DOWN"

declare OUTPUT

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

powered=$(ip a | grep "wlo1" | grep -c "state UP")

if (( ! ${powered} )); then
    printf '%s\n' "${POWER_OFF_FORMAT}"
    exit 0
fi


case "${format}" in
    
    0)
        netinfo=$(nmcli dev wifi list)
        name=$(echo "$netinfo" | grep "\*" | awk '{print $3}')
        signal=$(echo "$netinfo" | grep "\*" | awk '{print $8}')

        signal_glyph=${RAMP_SIGNAL[$(echo "scale=0;${signal}/100 * 4 + 1" | bc -l)]}
        
        OUTPUT+=${BIG_FONT}${signal_glyph}
        OUTPUT+=${NORMAL_FONT}${GLYPH_SEPERATOR}

        if [[ -n ${NETWORKS[${name}]} ]]; then
            OUTPUT+=${NETWORKS[${name}]}
        else
            OUTPUT+=${name}
        fi
    ;;
    
    1)
        rx_bytes=$(cat /sys/class/net/wlo1/statistics/rx_bytes)
        tx_bytes=$(cat /sys/class/net/wlo1/statistics/tx_bytes)
        sleep 1s
        rx_bytes=$(( $(cat /sys/class/net/wlo1/statistics/rx_bytes) - ${rx_bytes} ))
        tx_bytes=$(( $(cat /sys/class/net/wlo1/statistics/tx_bytes) - ${tx_bytes} ))

        down_speed=$(( ${rx_bytes} / 1024 ))
        up_speed=$(( ${tx_bytes} / 1024 ))

        OUTPUT+=${BIG_FONT}${UPLOAD_GLYPH}${NORMAL_FONT}
        OUTPUT+=${GLYPH_SEPERATOR}${GLYPH_SEPERATOR}
        OUTPUT+=${up_speed}

        OUTPUT+=${SECTION_SEPERATOR}
        
        OUTPUT+=${BIG_FONT}${DOWNLOAD_GLYPH}${NORMAL_FONT}
        OUTPUT+=${GLYPH_SEPERATOR}${GLYPH_SEPERATOR}
        OUTPUT+=${down_speed}
    ;;

    *) 
        echo "Invalid Format: ${format}" 
        exit 1
        ;;
    
esac

printf '%s\n' "${OUTPUT}"

echo "format=${format}" > ${STATUS_FILE}
