#!/bin/bash

format=0
FORMAT_FILE="/mnt/media/net.polybar"
LAST_RX_FILE="/mnt/media/net-last-rx.polybar"
LAST_TX_FILE="/mnt/media/net-last-tx.polybar"
FORMAT_COUNT=2

if [[ ! -s ${FORMAT_FILE} ]]; then
    echo "format=${format}" > ${FORMAT_FILE}
fi

rx_curr=$(cat /sys/class/net/wlo1/statistics/rx_bytes)
tx_curr=$(cat /sys/class/net/wlo1/statistics/tx_bytes)

if [[ ! -s ${LAST_RX_FILE} ]]; then
    echo ${rx_curr} > ${LAST_RX_FILE}
fi
if [[ ! -s ${LAST_TX_FILE} ]]; then
    echo ${tx_curr} > ${LAST_TX_FILE}
fi

BIG_FONT=%{T5}
NORMAL_FONT=%{T1}
ALERT_COLOR=%{F#89dceb}
NORMAL_COLOR=%{F#eba0ac}

GLYPH_SEPERATOR=%{O6}
SECTION_SEPERATOR=${ALERT_COLOR}%{O7}%{T11}▍%{T1} 

SPEED_UNIT="%{O1}k"

declare -A NETWORKS
NETWORKS["TP-Link_6E36_5G"]="TP-5G"
# NETWORKS["StormFiber-13C0"]="Storm"
NETWORKS["StormFiber-13C0-5G"]="Storm-5G"

INTERVAL=2
SIGNAL_MIN="-90"
SIGNAL_MAX="-40"

RAMP_SIGNAL=( 󰤯 󰤟 󰤢 󰤥 󰤨 )
OFF_GLYPH=󰤮%{O4}
UPLOAD_GLYPH=
DOWNLOAD_GLYPH=

POWER_OFF_FORMAT="${BIG_FONT}${NORMAL_COLOR}${OFF_GLYPH}${NORMAL_FONT}${ALERT_COLOR}${GLYPH_SEPERATOR}LO DOWN"

declare OUTPUT

while [[ ${#@} -gt 0 ]]; do
    case ${1} in 
        
        --toggle|-t) 
            format=$(cat ${FORMAT_FILE} | grep "format" | grep -Po "[0-9]")
            format=$(( (${format}+1) % ${FORMAT_COUNT}))
            ;;
            
        --update|-u)
            format=$(cat ${FORMAT_FILE} | grep "format" | grep -Po "[0-9]")
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
    echo "format=${format}" > ${FORMAT_FILE}
    shift 
done

powered=$(ip a | grep "wlo1" | grep -c "state UP")

if (( ! ${powered} )); then
    printf '%s\n' "${POWER_OFF_FORMAT}"
    exit 0
fi


case "${format}" in
    
    0)
        netinfo=$(iw dev wlo1 link)
        name=$(echo "$netinfo" | grep "SSID" | cut -d " " -f 2)
        signal=$(echo "$netinfo" | grep "signal" | cut -d " " -f 2)
        
        signal_percent=$(echo "scale=0; ( ($signal - ${SIGNAL_MIN})*100 / (${SIGNAL_MAX} - ${SIGNAL_MIN}) )" | bc -l)
        signal_glyph=${RAMP_SIGNAL[$(echo "scale=0;${signal_percent}/100 * 4 + 1" | bc -l)]}
        
        OUTPUT+=${BIG_FONT}${ALERT_COLOR}
        OUTPUT+=${signal_glyph}
        OUTPUT+=${NORMAL_FONT}${NORMAL_COLOR}

        OUTPUT+=${GLYPH_SEPERATOR}
        OUTPUT+=${GLYPH_SEPERATOR}

        if [[ -n ${NETWORKS[${name}]} ]]; then
            OUTPUT+=${NETWORKS[${name}]}
        else
            OUTPUT+=${name}
        fi
    ;;
    
    1)
        rx_prev=$(cat ${LAST_RX_FILE})
        tx_prev=$(cat ${LAST_TX_FILE})

        rx_diff=$(( ${rx_curr} - ${rx_prev} ))
        tx_diff=$(( ${tx_curr} - ${tx_prev} ))

        down_speed=$(( ${rx_diff} / (1024 * ${INTERVAL}) ))
        up_speed=$(( ${tx_diff} / (1024 * ${INTERVAL}) ))

        OUTPUT+=${BIG_FONT}${ALERT_COLOR}
        OUTPUT+=${UPLOAD_GLYPH}${NORMAL_FONT}
        OUTPUT+=${GLYPH_SEPERATOR}${GLYPH_SEPERATOR}
        OUTPUT+=${NORMAL_COLOR}${up_speed}${SPEED_UNIT}

        OUTPUT+=${SECTION_SEPERATOR}
        
        OUTPUT+=${BIG_FONT}${ALERT_COLOR}
        OUTPUT+=${DOWNLOAD_GLYPH}${NORMAL_FONT}
        OUTPUT+=${GLYPH_SEPERATOR}${GLYPH_SEPERATOR}
        OUTPUT+=${NORMAL_COLOR}${down_speed}${SPEED_UNIT}
    ;;

    *) 
        echo "Invalid Format: ${format}" 
        exit 1
        ;;
    
esac

printf '%s\n' "${OUTPUT}"

echo "format=${format}" > ${FORMAT_FILE}
echo ${rx_curr} > ${LAST_RX_FILE}
echo ${tx_curr} > ${LAST_TX_FILE}
