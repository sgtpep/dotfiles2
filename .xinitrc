#!/bin/bash
set -eu
product_name=$(path=/sys/class/dmi/id/product_name; [[ ! -f $path ]] || echo "$(< "$path")")
setxkbmap -option ctrl:nocaps,grp:shifts_toggle,grp:switch,lv3:switch,misc:typo us,ru
xrdb ~/.Xresources

[[ $product_name != VirtualBox ]] || /opt/VBoxGuestAdditions-*/other/98vboxadd-xclient &
[[ $product_name != VirtualBox ]] || { pactl set-sink-mute 0 no; pactl set-sink-volume 0 100%; } &
[[ $product_name != VirtualBox || ! -f ~/.job ]] || xmodmap ~/.Xmodmap-job &
battery-monitor &
devmon &
eval "$(dbus-launch --exit-with-session --sh-syntax)"
export SSH_AUTH_SOCK=/tmp/ssh-agent; ssh-agent -a "$SSH_AUTH_SOCK" &
start-pulseaudio-x11 &
{ sleep 1; exec xclipboard; } &

exec awesome
