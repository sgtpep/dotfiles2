#!/bin/bash
set -eu
setxkbmap -option ctrl:nocaps,grp:shifts_toggle,grp:switch,lv3:switch,misc:typo us,ru
xrdb ~/.Xresources

{ sleep 1; exec xclipboard; } &
[[ ! -c /dev/vboxguest ]] || { pactl set-sink-mute 0 no; pactl set-sink-volume 0 100%; } &
[[ ! -c /dev/vboxguest ]] || /opt/VBoxGuestAdditions-*/other/98vboxadd-xclient &
[[ ! -c /dev/vboxguest || ! -f ~/.job ]] || xmodmap ~/.Xmodmap-job &
[[ $(< /etc/os-release) != *ID=raspbian* ]] || xrdb -merge <<< 'Xft.dpi: 86'
battery-monitor &
devmon &
eval "$(dbus-launch --exit-with-session --sh-syntax)"
export SSH_AUTH_SOCK=/tmp/ssh-agent; ssh-agent -a "$SSH_AUTH_SOCK" &
start-pulseaudio-x11 &

exec awesome
