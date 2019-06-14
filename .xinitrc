#!/bin/bash
set -eu
. ~/.profile
exec >&-
setxkbmap -option ctrl:nocaps,grp:shifts_toggle,grp:switch,lv3:switch,misc:typo us,ru
xrdb ~/.Xresources

[[ ! -c /dev/vboxguest ]] || VBoxClient-all &
[[ ! -c /dev/vboxguest ]] || xset s off &
battery-monitor &

#[ ! -c /dev/vboxguest ] || pactl set-sink-volume 0 100% &
#[ ! -c /dev/vboxguest ] || xmodmap ~/.Xmodmap-virtualbox &
#[ "${DBUS_SESSION_BUS_ADDRESS-}" ] || eval "$(dbus-launch --exit-with-session --sh-syntax)"
#[ "${PULSE_SERVER-}"  ] || start-pulseaudio-x11 &
#[ "${SSH_AUTH_SOCK-}" ] || { export SSH_AUTH_SOCK=/tmp/ssh-agent; ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null & }
#[ "${TERMUX-}" ] || devmon &
#{ sleep 1; exec xclipboard; } &

exec awesome
