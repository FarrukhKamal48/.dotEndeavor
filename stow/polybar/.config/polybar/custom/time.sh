#!/bin/bash

icons=( 󱐿 󱑀 󱑁 󱑂 󱑃 󱑄 󱑅 󱑆 󱑇 󱑈 󱑉 󱑊 )

hour=$(($(date +%I)-1))
time=$(date "+%I:%M %P")

printf '%s\n' "%{T11}${icons[${hour}]}%{T1} ${time}"
