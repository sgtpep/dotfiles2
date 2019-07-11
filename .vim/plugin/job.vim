if filereadable(expand('~/.job'))
  autocmd BufNewFile,BufRead *.ts,*.tsx set filetype=javascript
endif
