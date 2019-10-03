[[ $- == *i* ]] || return 0

. /usr/lib/git-core/git-sh-prompt
. ~/.bash_aliases
. ~/.bash_bindings
[[ -v BASH_COMPLETION_COMPAT_DIR ]] || . /usr/share/bash-completion/bash_completion

((COLUMNS > 80)) || unset MANWIDTH
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM=auto
HISTCONTROL=ignoreboth
HISTFILESIZE=-1
HISTSIZE=10000
PROMPT_COMMAND=': "$?"; [[ $_ == 0 ]] || echo -e "\e[4mExit status: $_\e[m" >&2; history -a'
PS1=$'$([[ -h $PWD ]] && : "$(readlink "$PWD")" || : "$PWD"; while [[ $_ == ${HOME%/*}/* && ! -d $_/.git && $_ != ~ ]]; do : "${_%/*}"; done; [[ $_ == ~ ]] || __git_ps1 \'(%s) \')'$PS1
shopt -s autocd
stty -ixon
