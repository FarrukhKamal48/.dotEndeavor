#!/bin/bash

bar_height=30
volume_step=5
max_volume=150
brightness_step=5

function get_volume {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3}(?=%)' | head -1
}

function get_mute {
    pactl get-sink-mute @DEFAULT_SINK@ | grep -Po '(?<=Mute: )(yes|no)'
}

function get_brightness {
    brightnessctl i | grep -o '(.*%)' | sed 's/[()%]//g'
}

function set_volume_icon {
    volume=$(get_volume)
    mute=$(get_mute)
    if [[ "$mute" == "yes" ]]; then
        volume_icon=volume-mute
    elif (( $volume <= 35 )); then
        volume_icon=volume-low 
    elif (( $volume >= 36 && $volume <= 70 )); then
        volume_icon=volume-medium
    elif (( $volume >= 71 && $volume <= 100 )); then
        volume_icon=volume-high 
    else
        volume_icon=volume-ultra
    fi
}

function set_brightness_icon {
    # brightness=$(awk "BEGIN { print ($(get_brightness)/96000)*100; }")
    brightness=$(get_brightness)
    if (( $brightness <= 20 )) ; then
        brightness_icon=brightness-low
    elif (( $brightness >= 21 && $brightness <= 40 )); then
        brightness_icon=brightness-medium
    elif (( $brightness >= 41 && $brightness <= 60 )); then
        brightness_icon=brightness-half
    else
        brightness_icon=brightness-high
    fi
}

function show_volume_notif {
    volume=$(get_mute)
    set_volume_icon
    dunstify -a "volume_brightness" -u low -i $volume_icon -r 2594 -h int:value:"$volume" "${volume}%"
    
    # # bartxt=$(~/.dotEndeavor/config-stow/i3/.config/i3/scripts/tools/ascii-bar.sh \
    # #     $volume $bar_height $max_volume)
    # # dunstify -a "volume_bar" -r 2593 "$bartxt"
}

function show_brightness_notif {
    brightness=$(awk "BEGIN { print ($(get_brightness)/96000)*100; }")
    set_brightness_icon
    dunstify -a "volume_brightness" -u low -i $brightness_icon -r 2593 -h int:value:"$brightness" "${brightness}%"
}

case $1 in
    volume_up)
    # Unmutes and increases volume by percentage
    pactl set-sink-mute @DEFAULT_SINK@ 0
    volume=$(get_volume)
    if [ $(( "$volume" + "$volume_step" )) -gt $max_volume ]; then
        pactl set-sink-volume @DEFAULT_SINK@ $max_volume%
    else
        pactl set-sink-volume @DEFAULT_SINK@ +$volume_step%
    fi
    show_volume_notif
    ;;

    volume_down)
    # Decreases volume by percentage
    pactl set-sink-volume @DEFAULT_SINK@ -$volume_step%
    show_volume_notif
    ;;

    volume_mute)
    # Toggles mute
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    show_volume_notif
    ;;

    brightness_up)
    # Increases brightness by percentage
    currentBrightness=$(get_brightness)
    brightnessctl -q set $brightness_step%+ 
    show_brightness_notif
    ;;

    brightness_down)
    # Decreases brightness by percentage
    brightnessctl -q set $brightness_step%- 
    show_brightness_notif
    ;;
    
    brightness_notif)
    show_brightness_notif
    ;;

    volume_notif)
    show_volume_notif
    ;;
esac
