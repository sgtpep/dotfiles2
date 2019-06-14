#!/bin/bash
set -eu
. ~/.profile
exec >&-
setxkbmap -option ctrl:nocaps,grp:shifts_toggle,grp:switch,lv3:switch,misc:typo us,ru
xrdb ~/.Xresources

( sleep 1; exec xclipboard ) &
[[ ! -c /dev/vboxguest ]] || VBoxClient-all &
[[ ! -c /dev/vboxguest ]] || pactl set-sink-volume 0 100% &
[[ ! -c /dev/vboxguest ]] || xmodmap ~/.Xmodmap-job &
[[ ! -c /dev/vboxguest ]] || xset s off &
battery-monitor &
devmon &
eval "$(dbus-launch --exit-with-session --sh-syntax)"
export SSH_AUTH_SOCK=/tmp/ssh-agent; ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null &
start-pulseaudio-x11 &

exec awesome
