#!/bin/bash

case $1 in
    
    power_on)
    rfkill unblock bluetooth && sleep 1s && bluetoothctl power on
    ;;
    
    power_off)
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
