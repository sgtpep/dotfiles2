#!/bin/bash
set -eu
setxkbmap -option ctrl:nocaps,grp:shifts_toggle,grp:switch,lv3:switch,misc:typo us,ru
xrdb ~/.Xresources

(sleep 1; exec xclipboard) &
eval "$(dbus-launch --exit-with-session --sh-syntax)"
export SSH_AUTH_SOCK=/tmp/ssh-agent; ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null &
start-pulseaudio-x11 &
if [[ -c /dev/vboxguest ]]; then
  (pactl set-sink-mute 0 no; pactl set-sink-volume 0 100%) &
  /etc/X11/Xsession.d/98vboxadd-xclient &
  [[ ! -f ~/.job ]] || xmodmap ~/.Xmodmap-job &
elif [[ $(< /etc/os-release) == *ID=raspbian* ]]; then
  xrdb -merge <<< 'Xft.dpi: 86'
else
  battery-monitor &
  devmon &> /dev/null &
fi

exec awesome
