[[ $- == *i* ]] || return 0

. ~/.bash_aliases
. ~/.bash_bindings
[[ ! -f /usr/lib/git-core/git-sh-prompt ]] || . /usr/lib/git-core/git-sh-prompt

COMP_KNOWN_HOSTS_WITH_HOSTFILE=
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM=auto
HISTCONTROL=ignoreboth
HISTFILESIZE=-1
HISTSIZE=10000
PROMPT_COMMAND=': $?; [[ $_ == 0 ]] || echo -e "\e[4mExit status: $_\e[m" >&2; history -a'
PS1=$'$([[ $PWD == ~ || ! -d .git ]] || ! command -v __git_ps1 > /dev/null || __git_ps1 \'(%s) \')'$PS1
shopt -s autocd
stty -ixon