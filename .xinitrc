#!/bin/bash
set -eu

id=$(DISPLAY=:0 xwininfo -name Desktop | grep -Po '(?<= id: )\w+')
xev -display :0 -event structure -id "$id" | grep --line-buffered ConfigureNotify | while read; do
  xrandr &> /dev/null
done &

setxkbmap us,ru
xrdb ~/.Xresources

exec awesome
