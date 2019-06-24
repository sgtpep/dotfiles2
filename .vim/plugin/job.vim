if filereadable(expand('~/.job'))
  autocmd BufNewFile,BufRead *.jsx,*.ts,*.tsx set filetype=javascript
endif
