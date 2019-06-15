#!/bin/bash
set -eu
. ~/.profile
exec >&-

setxkbmap -option ctrl:nocaps,grp:shifts_toggle,grp:switch,lv3:switch,misc:typo us,ru
xrdb ~/.Xresources

(sleep 1; exec xclipboard) &
[[ ! -c /dev/vboxguest ]] || (pactl set-sink-mute 0 no; pactl set-sink-volume 0 100%) &
[[ ! -c /dev/vboxguest ]] || /etc/X11/Xsession.d/98vboxadd-xclient &
[[ ! -c /dev/vboxguest ]] || xmodmap ~/.Xmodmap-job &
[[ ! -c /dev/vboxguest ]] || xset s off &
battery-monitor &
devmon &> /dev/null &
eval "$(dbus-launch --exit-with-session --sh-syntax)"
export SSH_AUTH_SOCK=/tmp/ssh-agent; ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null &
start-pulseaudio-x11 &

exec awesome
