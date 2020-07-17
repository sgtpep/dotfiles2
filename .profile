export CARGO_HOME=~/.cargo
export DENO_HOME=~/.deno
export EDITOR=vim
export GEM_HOME=~/.gem
export LESS='-FRXi -j 3'
export MANWIDTH=80
export NO_COLOR=1
export NPM_CONFIG_PREFIX=~/.npm
export PYTHONUSERBASE=~/.pip
export RIPGREP_CONFIG_PATH=~/.ripgreprc

[ "${PATH/~}" != "$PATH" ] || export PATH=$CARGO_HOME/bin:$DENO_HOME/bin:$GEM_HOME/bin:$NPM_CONFIG_PREFIX/bin:$PYTHONUSERBASE/bin:~/.local/bin:$PATH:node_modules/.bin
if [ "$TERM" = linux ] && [ "$XDG_VTNR" = 1 ]; then
  exec xinit -- vt"$XDG_VTNR" >> /tmp/xinit.log 2>&1
elif [ "${BASH-}" ]; then
  . ~/.bashrc
fi
