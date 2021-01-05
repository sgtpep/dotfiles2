#!/bin/bash
set -eu
setxkbmap us,ru -option ctrl:nocaps,grp:rshift_toggle,lv3:ralt_switch,misc:typo
xrdb ~/.Xresources

if [[ $(< /sys/class/dmi/id/product_name) == Parallels\ * ]]; then
  export GDK_DPI_SCALE=0.5 GDK_SCALE=2
  pactl set-sink-mute 0 no
  setxkbmap -option altwin:swap_lalt_lwin,lv3:rwin_switch
  xrdb -merge <<< 'Xft.dpi: 192'
fi

battery-monitor &
clipit -d &
eval "$(dbus-launch --exit-with-x11 --sh-syntax)"
export SSH_AUTH_SOCK=/tmp/ssh-agent; ssh-agent -a "$SSH_AUTH_SOCK" &
start-pulseaudio-x11 &
udisks-monitor &

exec awesome
