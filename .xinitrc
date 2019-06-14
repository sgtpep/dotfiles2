#!/bin/bash
set -eu
. ~/.profile
exec >&-
setxkbmap -option ctrl:nocaps,grp:shifts_toggle,grp:switch,lv3:switch,misc:typo us,ru
xrdb ~/.Xresources

#[ ! "${TERMUX-}" ] && [ ! -c /dev/vboxguest ] || battery-monitor &
#[ ! "${TERMUX-}" ] && [ ! -c /dev/vboxguest ] || xset s off &
#[ ! "${TERMUX-}" ] || echo 'Xft.dpi: 120' | xrdb -merge &
#[ ! -c /dev/vboxguest ] || VBoxClient-all &
#[ ! -c /dev/vboxguest ] || pactl set-sink-volume 0 100% &
#[ ! -c /dev/vboxguest ] || xmodmap ~/.Xmodmap-virtualbox &
#[ "${DBUS_SESSION_BUS_ADDRESS-}" ] || eval "$(dbus-launch --exit-with-session --sh-syntax)"
#[ "${PULSE_SERVER-}"  ] || start-pulseaudio-x11 &
#[ "${SSH_AUTH_SOCK-}" ] || { export SSH_AUTH_SOCK=/tmp/ssh-agent; ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null & }
#[ "${TERMUX-}" ] || devmon &
#{ sleep 1; exec xclipboard; } &

exec awesome
