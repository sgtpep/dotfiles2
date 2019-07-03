alias cal='ncal -Mb'
alias cp='cp -i'
alias dd='dd conv=fsync bs=4M'
alias df='df -h'
alias du='du -h'
alias fd='fd -H -c never'
alias free='free -h'
alias grep='paginate grep --color'
alias json='paginate python -m json.tool'
alias ls='ls -h'
alias mv='mv -i'
alias pngquant='pngquant -f --ext=.png'
alias rclone='aws rclone'
alias rg='paginate rg -p'
alias rm='rm -I'
alias sdcv='sdcv --color'
alias sxiv='sxiv -r'
alias vi=vim
alias watch='watch '

function git {
  set -- "${FUNCNAME[0]}" "$@"
  if [[ ${2-} =~ ^(clone|pull)$ ]]; then
    online "$@"
  else
    command "$@"
  fi
}

function paginate {
  "$@" |& less
}

function pwdhash {
  command "${FUNCNAME[0]}" "$@" | xclip -selection clipboard
}
