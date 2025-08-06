#!/bin/bash

off_glyph="󰂲"
off_text="OFF"

on_glyph="󰂯"
on_text="ON"

connected_glyph="󰋋"

case $1 in
    
    power_toggle)
    powered=$(bluetoothctl show | grep 'Powered:' | sed 's/.*: //g')
    if [[ "$powered" == "yes" ]]; then
        ~/.scripts/tools/bluetooth.sh power_off
    else
        ~/.scripts/tools/bluetooth.sh power_on
    fi
    ;;

    format)
    powered=$(bluetoothctl show | grep 'Powered:' | sed 's/.*: //g')
    connected=$(bluetoothctl info | grep 'Connected:' | sed 's/.*: //g')

    glyph_color_normal="%{F#eba0ac}"
    glyph_color_alert="%{F#89dceb}"
    text_color_normal="%{F#eba0ac}"

    icon=""
    icon_color="${glyph_color_normal}"
    text=""
    text_color="${text_color_normal}"

    if [[ "$powered" == "yes" ]]; then
        icon=${on_glyph}
        icon_color="${glyph_color_alert}"
        text=${on_text}
    else
        icon=${off_glyph}
        icon_color="${glyph_color_alert}"
        text=${off_text}
    fi

    if [[ "$connected" == "yes" ]]; then
        icon=${connected_glyph}
        icon_color="${glyph_color_normal}"
        device=$(bluetoothctl info | grep 'Alias' | sed 's/.*: //g' | awk '{print $1}')
        battery=$(bluetoothctl info | grep 'Battery Percentage' | sed 's/.*(//g' | cut -d ')' -f 1)'%'
        text="${device} ${battery}"
    fi

    echo "%{T7}${icon_color}${icon}%{T1} ${text_color}${text}"
    ;;

esac
