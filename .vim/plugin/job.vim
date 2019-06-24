if filereadable(expand('~/.job'))
  autocmd BufNewFile,BufRead *.jsx,*.ts,*.tsx set filetype=javascript
  set suffixesadd=.js,.jsx,.ts.,.tsx
endif
