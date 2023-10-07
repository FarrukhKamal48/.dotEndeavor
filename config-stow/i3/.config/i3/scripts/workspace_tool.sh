#!/bin/bash

MAX_DESKTOPS=20
next_ws=1
prev_ws=1
empty_ws=1

function get_activeWorkspace {
    i3-msg -t get_workspaces \
      | jq '.[] | select(.focused==true).name' \
      | cut -d"\"" -f2
}

# switch to workspace with number one less than current
function decrement_workspace {
    current=$(get_activeWorkspace)
    prev_ws=$(( $current - 1 )) 
}

# switch to workspace with number one more than current
function increment_workspace {
    current=$(get_activeWorkspace)
    next_ws=$(( $current + 1 ))
}

function empty_workspace {

    WORKSPACES=$(seq -s '\n' 1 1 ${MAX_DESKTOPS})

    empty_ws=$( (i3-msg -t get_workspaces | tr ',' '\n' | grep num | awk -F:  '{print int($2)}' ; \
                echo -e ${WORKSPACES} ) | sort -n | uniq -u | head -n 1)

}

case $1 in
    prev)
    decrement_workspace
    i3-msg workspace $prev_ws
    ;;

    next)
    increment_workspace
    i3-msg workspace $next_ws
    ;;

    empty)
    empty_workspace
    i3-msg workspace $empty_ws
    ;;

    take-prev)
    decrement_workspace
    i3-msg move container to workspace $prev_ws; i3-msg workspace $prev_ws
    ;;

    take-next)
    increment_workspace
    i3-msg move container to workspace $next_ws; i3-msg workspace $next_ws
    ;;

    take-empty)
    empty_workspace
    i3-msg move container to workspace $empty_ws; i3-msg workspace $empty_ws
    ;;

esac
