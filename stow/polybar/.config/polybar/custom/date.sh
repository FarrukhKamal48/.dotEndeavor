#!/bin/bash

icon=󰙹
date=$(date "+%d-%b %a")

printf '%s\n' "%{T11}${icon}%{T1} ${date}"
