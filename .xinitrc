#!/bin/bash
set -eu
xrdb ~/.Xresources
[[ $(< /etc/os-release) != *=raspbian* ]] || raspbian=1
path=/sys/class/dmi/id/product_name; [[ ! -f $path ]] || product=$(< "$path")
[[ ${product-} != Parallels\ * ]] || parallels=1
[[ ! -v parallels || $(xrandr) != *' 2880x1800+'* ]] || macbook=1
[[ ${product-} != VirtualBox ]] || virtualbox=1

[[ ! -v macbook ]] || export GDK_SCALE=2 GDK_DPI_SCALE=0.5 PATH=~/google-cloud-sdk/bin:$PATH
[[ ! -v macbook ]] || xrdb -merge <<< 'Xft.dpi: 192'
[[ ! -v parallels && ! -v virtualbox ]] || { pactl set-sink-mute 0 no; pactl set-sink-volume 0 100%; } &
[[ ! -v parallels ]] || { setxkbmap -option altwin:swap_alt_win,lv3:rwin_switch; xmodmap ~/.Xmodmap-"$([[ -v macbook ]] && echo macbook || echo parallels)"; } &
[[ ! -v raspbian ]] || { xset s 60; sudo xss-lock -n screensaver true; } &
[[ ! -v virtualbox ]] || VBoxClient-all &
[[ ! -v virtualbox ]] || xset -dpms &
[[ -v parallels || -v virtualbox ]] || unclutter -idle 1 -root &
[[ -v raspbian ]] || battery-monitor &
eval "$(dbus-launch --exit-with-x11 --sh-syntax)"
export SSH_AUTH_SOCK=/tmp/ssh-agent; ssh-agent -a "$SSH_AUTH_SOCK" &
start-pulseaudio-x11 &
udisks-monitor &
{ sleep 1; exec xclipboard; } &

exec awesome
