export CHROMIUM_FLAGS=--disable-smooth-scrolling
export LESS='-FRXi -j 3'
export MANWIDTH=80
export NPM_CONFIG_PREFIX=~/.npm
export PYTHONUSERBASE=~/.pip
export RIPGREP_CONFIG_PATH=~/.ripgreprc
export SDCV_PAGER=less

[ "${PATH/~}" != "$PATH" ] || export PATH=~/.local/bin:$PATH:$NPM_CONFIG_PREFIX/bin:$PYTHONUSERBASE/bin
path=~/.profile_local && ( [ ! -f "$path" ] || . "$path" ) && unset path
[ ! "${BASH-}" ] || . ~/.bashrc
