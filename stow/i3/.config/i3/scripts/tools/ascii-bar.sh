#!/bin/bash

FILL_PERCENT=$1
BAR_HEIGHT=$2
MAX_PERCENT=$3

FILLED_CHAR="█"
EMPTY_CHAR="░"

filled_count=$(( (FILL_PERCENT * BAR_HEIGHT) / MAX_PERCENT ))
empty_count=$(( BAR_HEIGHT - filled_count ))

for ((j=0; j<empty_count; j++)); do
    echo "$EMPTY_CHAR"
done

for ((j=0; j<filled_count; j++)); do
    echo "$FILLED_CHAR"
done

