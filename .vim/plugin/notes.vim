if getcwd() ==# expand('~/notes')
  function s:sync()
    update
    let output = system('sync-notes')
    if v:shell_error
      echo output
    endif
    checktime
  endfunction
  nnoremap <silent> <Leader>T :edit tasks<CR>
  nnoremap <silent> <Leader>s :call <SID>sync()<CR>
  nnoremap <silent> <Leader>t :find todo<CR>
  nnoremap <silent> <Leader>w :edit job<CR>
endif
