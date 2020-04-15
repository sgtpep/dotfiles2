export CARGO_HOME=~/.cargo
export EDITOR=vim
export GEM_HOME=~/.gem
export HUSKY_SKIP_HOOKS=1
export LESS='-FRXi -j 3'
export MANWIDTH=80
export NODE_PATH=~/.npm/lib/node_modules
export NO_COLOR=1
export PYTHONUSERBASE=~/.pip
export RIPGREP_CONFIG_PATH=~/.ripgreprc

[ "${PATH/~}" != "$PATH" ] || export PATH=$CARGO_HOME/bin:$GEM_HOME/bin:${NODE_PATH%/*/*}/bin:$PYTHONUSERBASE/bin:~/.cargo:~/.local/bin:$PATH
if [ "$TERM" = linux ] && [ "$XDG_VTNR" = 1 ]; then
  exec xinit -- vt"$XDG_VTNR" >> /tmp/xinit.log 2>&1
elif [ "${BASH-}" ]; then
  . ~/.bashrc
fi
