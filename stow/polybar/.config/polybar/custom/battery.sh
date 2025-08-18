#!/bin/bash

# upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep "state:" | awk '{print $2}'

charging_color=#a6e3a1
discharging_color=#fab387
full_color=#89b4fa
low_color=#f38ba8

ramp_capacity=( 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹 )
charging_icon=%{T5}%{F${charging_color}}󰂄%{T1}%{F${full_color}}
plugged_icon=
icon_spacer=%{O4}

full_level=80
low_level=50

plugged=$(cat "/sys/class/power_supply/ADP1/online")
bat_status=$(cat "/sys/class/power_supply/BAT1/status")
bat_level=$(cat "/sys/class/power_supply/BAT1/capacity")

# different colors or discharging and stable
if [[ ${bat_status} = "Discharging" ]]; then
    ramp_color=${discharging_color}
elif [[ ${bat_status} = "Not charging" ]]; then
    ramp_color=${full_color}
fi

# color overrides for extremes
if (( ${bat_level} <= ${low_level})); then
    ramp_color=${low_color}
elif (( ${bat_level} >= ${full_level})); then
    ramp_color=${full_color}
fi


ramp_icon=%{T5}%{F${ramp_color}}

if (( ${bat_level} <= ${low_level} )); then
    ramp_icon+=${ramp_capacity[0]}
elif (( ${bat_level} >= ${full_level} )); then
    ramp_icon+=${ramp_capacity[-1]}
else
    ramp_icon+=${ramp_capacity[(( ${bat_level}/${#ramp_capacity[@]} - 1 ))]}
fi

ramp_icon+=%{T1}%{F${full_color}}

time_remaining=$(acpi | tail -1 | awk '{print $5}' | cut -c -5)
if [[ -n "${time_remaining}" ]]; then
    time_remaining=" ${time_remaining}"
fi

case ${bat_status} in
    "Charging")
        printf '%s%s%s%s' "${charging_icon}" "${icon_spacer}" "${bat_level}%" "${time_remaining}"
        ;;
    "Discharging")
        printf '%s%s%s%s' "${ramp_icon}" "${icon_spacer}" "${bat_level}%" "${time_remaining}"
        ;;
    * )
        printf '%s%s%s' "${ramp_icon}" "${icon_spacer}" "${bat_level}%"
        ;;
esac


