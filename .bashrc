[[ $- == *i* ]] || return 0

((COLUMNS > 80)) || unset MANWIDTH
. /usr/lib/git-core/git-sh-prompt
. ~/.bash_aliases
. ~/.bash_bindings
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM=auto
HISTCONTROL=ignoreboth
HISTFILESIZE=-1
HISTIGNORE=y
HISTSIZE=10000
PROMPT_COMMAND=': "$?" && [[ $_ == 0 ]] || echo -e "\e[4mExit status: $_\e[m" >&2; history -a'
PS1=$'$(if [[ -h $PWD ]]; then : "$(readlink "$PWD")"; else : "$PWD"; fi && while [[ $_ == ${HOME%/*}/* && ! -d $_/.git ]]; do : "${_%/*}"; done && [[ $_ != ~ ]] && __git_ps1 \'(%s) \')'${PS1/\w/\W}
[[ -v BASH_COMPLETION_COMPAT_DIR ]] || . /etc/bash_completion
shopt -s autocd
stty -ixon
