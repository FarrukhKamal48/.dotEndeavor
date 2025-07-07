#!/usr/bin/env bash

if [ -f $1 ] ; then
  case $1 in
     *.tar.bz2)   tar xjf $1      ;;
     *.tar.gz)   tar xf $1 --one-top-level;;
     *.bz2)      bunzip2 $1      ;;
     *.rar)      rar x $1      ;;
     *.gz)      gunzip $1      ;;
     *.tar)      tar xf $1      ;;
     *.tbz2)      tar xjf $1      ;;
     *.tgz)      tar xf $1      ;;
     *.zip)      unzip $1      ;;
     *.Z)      uncompress $1   ;;
     *)         echo "'$1' cannot be extracted via extract()" ;;
  esac
else
  echo "'$1' is not a valid file"
fi
