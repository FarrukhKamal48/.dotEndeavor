#!/bin/bash

glyph=
used=$(free -h | awk '{print $3}' | head -n 2 | tail -n 1)

case $1 in
    
    format)
    printf '%s\n' "${glyph}  ${used}" 
    ;;
    
    format-alt)
    tot=$(free -h | awk '{print $2}' | head -n 2 | tail -n 1)
    printf '%s\n' "${glyph}  ${used}/${tot}" 
    ;;
    
esac

