#!/bin/bash
set -eu
product_name=$(path=/sys/class/dmi/id/product_name; [[ ! -f $path ]] || echo "$(< "$path")")
setxkbmap -option ctrl:nocaps,grp:rshift_toggle,grp:switch,lv3:switch,misc:typo us,ru
xrdb ~/.Xresources

[[ $product_name != 'HP Stream '* ]] || xinput set-prop 'ETPS/2 Elantech Touchpad' 'libinput Tapping Enabled' 1
[[ $product_name != VirtualBox ]] || /opt/VBoxGuestAdditions-*/other/98vboxadd-xclient &
[[ $product_name != VirtualBox ]] || { pactl set-sink-mute 0 no; pactl set-sink-volume 0 100%; } &
[[ $product_name != VirtualBox || ! -f ~/.job ]] || xmodmap ~/.Xmodmap-job &
battery-monitor &
eval "$(dbus-launch --exit-with-session --sh-syntax)"
export SSH_AUTH_SOCK=/tmp/ssh-agent; ssh-agent -a "$SSH_AUTH_SOCK" &
start-pulseaudio-x11 &
udisks-monitor &
unclutter -idle 1 -root &
{ sleep 1; exec xclipboard; } &

exec awesome
