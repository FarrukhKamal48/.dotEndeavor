#!/bin/bash

while [[ ${#@} -gt 0 ]]; do
    case ${1} in 

        --launch|-l)
            if (( ! $(killall -v -q polybar | grep -c "Killed") )); then
                killall -s KILL polybar
            fi

            echo "---" | tee -a /tmp/polybar-mainbar.log 
            polybar mainbar 2>&1 | tee -a /tmp/polybar-mainbar.log & disown

            echo "Bars launched..."
            ;;
        
        --update|-u)
            modules=($(cat .config/polybar/config.ini | grep "\[module" | sed 's/\[module\///g;s/\]//g'))
            types=($(cat .config/polybar/config.ini | grep "type = " | sed 's/interface.*//g;s/type = //g'))

            for i in ${!modules[@]}; do
                if [[ ${types[${i}]} = "custom/ipc" ]]; then
                    polybar-msg action "#${modules[${i}]}.hook.0"
                fi
            done
            ;;

        *) 
            echo "Unkown Argument: ${1}" 
            exit 1
            ;;
        
    esac
    shift
done

