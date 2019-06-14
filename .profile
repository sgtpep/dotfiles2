[ "${PATH%%:*}" = ~/.local/bin ] || export PATH=~/.local/bin:$PATH:node_modules/.bin:~/.gem/ruby/2.6.0/bin:~/.npm/bin
export EDITOR=vim
export LESS='-FRX -j 3'
export MANWIDTH=78
export NODE_PATH=~/.npm/lib/node_modules
export PIP_USER=yes

if [ "$TERM" = linux ] && [ "$XDG_VTNR" = 1 ] && ! pgrep -x xinit > /dev/null; then
  [ -x /usr/bin/"$(readlink ~/.local/bin/x-terminal-emulator)" ] || x-terminal-emulator -h > /dev/null 2>&1
  exec sh -c 'xinit -- vt"$XDG_VTNR" 2>&1 | sed '\''s/^/\r/'\'' >&2'
elif [ "${BASH-}" ] && [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
