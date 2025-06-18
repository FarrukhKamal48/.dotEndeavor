#!/bin/bash

snip_dir=$1
snip_format=$2
name=$3

if [[ -z "$name" ]]; then
    name=$(date +%s)
fi

snip_path=$snip_dir/$name.$snip_format

maim --hidecursor --quality 10 --select --format $snip_format $snip_path

cat $snip_path | copyq write image/$snip_format -
