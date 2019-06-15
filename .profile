[ "${PATH/~}" != "$PATH" ] || export PATH=~/.gem/ruby/2.6.0/bin:~/.npm/bin:~/.pip/bin:~/.local/bin:$PATH:node_modules/.bin
export EDITOR=vim
export LESS='-FRX -j 3'
export MANWIDTH=78
export NODE_PATH=~/.npm/lib/node_modules
export PYTHONUSERBASE=~/.pip

if [ "$TERM" = linux ] && [ "$XDG_VTNR" = 1 ] && ! pgrep -x xinit > /dev/null; then
  exec xinit -- vt"$XDG_VTNR" > /tmp/xinit.log 2>&1
elif [ "${BASH-}" ]; then
  . ~/.bashrc
fi
