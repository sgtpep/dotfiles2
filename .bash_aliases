alias copy='xsel -b'
alias cp='cp -i'
alias dd='dd bs=4M oflag=sync status=progress'
alias df='df -h'
alias du='du -h'
alias json='python3 -m json.tool'
alias ls='ls -h'
alias mv='mv -i'
alias rm='rm -I'
alias serve='python3 -m http.server'
alias watch='watch '

function rg {
  command rg -p "$@" |& less
  return "${PIPESTATUS[0]}"
}

function sshuttle {
  command sshuttle -r personal -x "$(ssh -G personal | grep -Po '(?<=^hostname ).+')" --dns 0/0 |& grep -v DeprecationWarning
}
