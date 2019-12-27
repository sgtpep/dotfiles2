#!/bin/bash
set -eu
[[ $(< /etc/os-release) != *=raspbian* ]] || raspbian=1
path=/sys/class/dmi/id/product_name; [[ ! -f $path || $(< "$path") != VirtualBox ]] || virtualbox=1
xrdb ~/.Xresources

[[ ! -v virtualbox ]] || /opt/VBoxGuestAdditions-*/other/98vboxadd-xclient &
[[ ! -v virtualbox ]] || xset -dpms &
[[ ! -v virtualbox ]] || { pactl set-sink-mute 0 no; pactl set-sink-volume 0 100%; } &
[[ ! -v virtualbox || ! -f ~/.job ]] || xmodmap ~/.Xmodmap-job &
[[ -v raspbian ]] || battery-monitor &
[[ -v virtualbox ]] || unclutter -idle 1 -root &
eval "$(dbus-launch --exit-with-x11 --sh-syntax)"
export SSH_AUTH_SOCK=/tmp/ssh-agent; ssh-agent -a "$SSH_AUTH_SOCK" &
start-pulseaudio-x11 &
udisks-monitor &
{ sleep 1; exec xclipboard; } &

exec awesome
