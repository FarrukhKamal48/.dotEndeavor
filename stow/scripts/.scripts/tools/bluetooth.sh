#!/bin/bash

off_glyph="󰂲"
off_text="OFF"

on_glyph="󰂯"
on_text="ON"

connected_glyph="󰋋"

case $1 in
    
    power_on)
    rfkill unblock bluetooth && sleep 1s && bluetoothctl power on
    ;;
    
    power_off)
    bluetoothctl power off && sleep 1s && rfkill block bluetooth
    ;;
    
    power_toggle)
    powered=$(bluetoothctl show | grep 'Powered:' | sed 's/.*: //g')
    if [[ "$powered" == "yes" ]]; then
        ~/.config/i3/scripts/tools/bluetooth.sh power_off
    else
        ~/.config/i3/scripts/tools/bluetooth.sh power_on
    fi
    ;;

    list_connected)
    bluetoothctl devices Connected | grep 'Device'
    ;;

    disconnect_all)
    for mac in $(bluetoothctl devices Connected | grep 'Device' | awk '{print $2}') 
    do
        bluetoothctl disconnect $mac
    done
    ;;

    status)
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

    if [[ "$2" == "polybar" ]]; then
        echo "%{T7}${icon_color}${icon} %{T1}${text_color}${text}"
    elif [[ -z "$2" ]]; then
        echo "${icon} ${text}"
    fi
    ;;

esac
