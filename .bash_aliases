alias ag='ag --hidden --pager=less'
alias cal='ncal -Mb'
alias cp='cp -i'
alias dd='dd conv=fsync bs=4M'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias json='python -m json.tool |& less'
alias ls='ls -h'
alias mv='mv -i'
alias pngquant='pngquant -f --ext=.png'
alias rclone='aws rclone'
alias rm='rm -I'
alias sdcv='sdcv --color'
alias sxiv='sxiv -r'
alias vi=vim
alias watch='watch '

function git {
  if [[ ${1-} == pull ]]; then
    execute-online git "$1"
  else
    command git "$@"
  fi
}

function grep {
  grep --color "$@" |& less
}
