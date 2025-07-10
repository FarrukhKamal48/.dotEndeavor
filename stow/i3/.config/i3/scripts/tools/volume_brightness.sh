#!/bin/bash

bar_height=30
volume_step=5
max_volume=150
brightness_step=5

get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3}(?=%)' | head -1
}

get_mute() {
    pactl get-sink-mute @DEFAULT_SINK@ | grep -Po '(?<=Mute: )(yes|no)'
}

get_brightness() {
    brightnessctl i | grep -Po '[0-9]{1,3}(?=%)'
}

update_volume() {
    volume=$(get_volume)
    mute=$(get_mute)
    if [[ "$mute" == "yes" ]]; then
        volume_icon=volume-mute
        volume_glyph=󰝟
    elif (( $volume <= 35 )); then
        volume_icon=volume-low 
        volume_glyph=󰕿
    elif (( $volume >= 36 && $volume <= 70 )); then
        volume_icon=volume-medium
        volume_glyph=󰖀
    elif (( $volume >= 71 && $volume <= 100 )); then
        volume_icon=volume-high 
        volume_glyph=󰕾
    else
        volume_icon=volume-ultra
        volume_glyph=󰝝
    fi
}

update_brightness() {
    brightness=$(get_brightness)
    if (( $brightness <= 20 )) ; then
        brightness_icon=brightness-low
        brightness_glyph=󰃞
    elif (( $brightness >= 21 && $brightness <= 40 )); then
        brightness_icon=brightness-medium
        brightness_glyph=󰃝
    elif (( $brightness >= 41 && $brightness <= 60 )); then
        brightness_icon=brightness-half
        brightness_glyph=󰃟 
    else
        brightness_icon=brightness-high
        brightness_glyph=󰃠 
    fi
}

show_volume_notif() {
    update_volume
    dunstify -a "volume_brightness" -u low -i $volume_icon -r 2594 -h int:value:"$volume" "${volume}%"
    
    polybar-msg action "#volume.hook.0"
    polybar-msg action "#volume-icon.hook.0"
    
    # # bartxt=$(~/.dotEndeavor/config-stow/i3/.config/i3/scripts/tools/ascii-bar.sh \
    # #     $volume $bar_height $max_volume)
    # # dunstify -a "volume_bar" -r 2593 "$bartxt"
}

show_brightness_notif() {
    update_brightness
    dunstify -a "volume_brightness" -u low -i $brightness_icon -r 2593 -h int:value:"$brightness" "${brightness}%"
    
    polybar-msg action "#brightness.hook.0"
    polybar-msg action "#brightness-icon.hook.0"
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
    brightnessctl -q set $brightness_step%+ 
    show_brightness_notif
    ;;

    brightness_down)
    # Decreases brightness by percentage
    brightnessctl -q set $brightness_step%- 
    show_brightness_notif
    ;;
    
    brightness_off)
    # Decreases brightness by percentage
    brightnessctl -q set 0
    show_brightness_notif
    ;;
    
    brightness_notif)
    show_brightness_notif
    ;;

    volume_notif)
    show_volume_notif
    ;;

    echo_volume_glyph)
    update_volume
    echo $volume_glyph
    ;;
    
    echo_volume_percent)
    update_volume
    echo $volume
    ;;
    
    echo_brightness_glyph)
    update_brightness
    echo $brightness_glyph
    ;;
    
    echo_brightness_percent)
    update_brightness
    echo $brightness
    ;;
esac
