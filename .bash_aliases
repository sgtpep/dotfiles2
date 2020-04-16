alias cal='ncal -b'
alias copy='xclip -selection clipboard'
alias cp='cp -i'
alias dd='dd bs=4M oflag=sync status=progress'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias grep='paginate grep'
alias json='paginate python -m json.tool'
alias ls='ls -h'
alias mv='mv -i'
alias pngquant='pngquant -f --ext=.png'
alias rclone='aws rclone'
alias rg='paginate rg -p --sort=path'
alias rm='rm -I'
alias sxiv='sxiv -r'
alias vi=vim
alias watch='watch '

function paginate {
  "$@" |& less
  return "${PIPESTATUS[0]}"
}
