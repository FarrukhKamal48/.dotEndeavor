#!/bin/bash

powered=$(bluetoothctl show | grep -c "Powered: yes")

case $1 in
    
    power_on)
        if (( ! ${powered} )); then
            dunstify -a "bluetooth.sh" -u low -i bluetooth -r 2595 "Bluetooth" "Power On"
        fi
        rfkill unblock bluetooth && sleep 1s && bluetoothctl power on
    ;;
    
    power_off)
        if (( ${powered} )); then
            dunstify -a "bluetooth.sh" -u low -i bluetooth-off -r 2595 "Bluetooth" "Power Off"
        fi
        bluetoothctl power off && sleep 1s && rfkill block bluetooth
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

esac
