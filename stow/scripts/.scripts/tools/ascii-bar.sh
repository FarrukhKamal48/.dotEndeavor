#!/bin/bash

FILL_PERCENT=$1
BAR_HEIGHT=$2
MAX_PERCENT=$3

FILLED_CHAR="██"
EMPTY_CHAR="░░"

filled_count=$(( (FILL_PERCENT * BAR_HEIGHT) / MAX_PERCENT ))
empty_count=$(( BAR_HEIGHT - filled_count ))

declare OUTPUT

for ((j=0; j<empty_count; j++)); do
    OUTPUT+=${EMPTY_CHAR};
    OUTPUT+="&#x0a;"
done

for ((j=0; j<filled_count; j++)); do
    OUTPUT+=${FILLED_CHAR};
    OUTPUT+="&#x0a;"
done

ROFI_WIDTH=4
ROFI_OPTIONS=(-no-fixed-num-lines \ 
    -theme ~/.config/rofi/custom-dmenu.rasi \
    -theme-str "window { width: ${ROFI_WIDTH}ch;}"
)

launcher_options=(-i -lines "${BAR_HEIGHT}" -p "${ROFI_PROMPT}" "${ROFI_OPTIONS[@]}" -dmenu)
rofi "${launcher_options[@]}" -mesg ${OUTPUT}


