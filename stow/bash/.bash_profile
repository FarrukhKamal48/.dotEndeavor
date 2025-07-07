#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec startx /usr/bin/i3
elif [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty2 ]]; then 
    export DESKTOP_SESSION=plasma
    exec startx /usr/bin/startplasma-x11
fi

	
