#!/bin/bash

ramp=( 󱐿 󱑀 󱑁 󱑂 󱑃 󱑄 󱑅 󱑆 󱑇 󱑈 󱑉 󱑊 )

hour=$(($(date "+%l")-1))
time=$(date "+%I:%M %P")

printf '%s\n' "%{T11}${ramp[${hour}]}%{T1} ${time}"
