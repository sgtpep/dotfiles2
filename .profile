export EDITOR=vim
export LESS='-FRXi -j 3'
export MANWIDTH=80
export NO_COLOR=true
export NPM_CONFIG_PREFIX=~/.npm
export PYTHONUSERBASE=~/.pip
export RIPGREP_CONFIG_PATH=~/.ripgreprc
export SDCV_PAGER=less

[ "${PATH/~}" != "$PATH" ] || export PATH=~/.local/bin:$PATH:$NPM_CONFIG_PREFIX/bin:$PYTHONUSERBASE/bin
path=~/.profile_local
[[ ! -f $path ]] || . "$path"
if [ "$TERM" = linux ] && [ "$XDG_VTNR" = 1 ]; then
  exec xinit -- vt"$XDG_VTNR" >> /tmp/xinit.log 2>&1
elif [ "${BASH-}" ]; then
  . ~/.bashrc
fi
