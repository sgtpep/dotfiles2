#!/bin/bash
set -eu
[[ $(< /etc/os-release) != *=raspbian* ]] || raspbian=1
path=/sys/class/dmi/id/product_name; [[ ! -f $path ]] || product=$(< "$path")
[[ ${product-} != Parallels\ * ]] || parallels=1
[[ ${product-} != VirtualBox ]] || virtualbox=1
xrdb ~/.Xresources

[[ ! -v parallels ]] || xrdb -merge <<< 'Xft.dpi: 196'
[[ ! -v parallels ]] || { setxkbmap -option altwin:swap_alt_win; xmodmap ~/.Xmodmap-parallels; } &
[[ ! -v raspbian ]] || { xset s 60; sudo xss-lock -n screensaver true; } &
[[ ! -v virtualbox ]] || VBoxClient-all &
[[ ! -v virtualbox ]] || xset -dpms &
[[ ! -v virtualbox ]] || { pactl set-sink-mute 0 no; pactl set-sink-volume 0 100%; } &
[[ -v raspbian ]] || battery-monitor &
[[ -v virtualbox ]] || unclutter -idle 1 -root &
eval "$(dbus-launch --exit-with-x11 --sh-syntax)"
export SSH_AUTH_SOCK=/tmp/ssh-agent; ssh-agent -a "$SSH_AUTH_SOCK" &
start-pulseaudio-x11 &
udisks-monitor &
{ sleep 1; exec xclipboard; } &

exec awesome
