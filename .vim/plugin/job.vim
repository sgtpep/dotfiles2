if !empty(glob('/dev/vboxguest'))
  autocmd BufNewFile,BufRead *.jsx,*.ts,*.tsx set filetype=javascript
endif
