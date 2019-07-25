if getcwd() ==# expand('~/notes')
  function s:sync_notes()
    update
    let output = system('online sync-notes')
    if v:shell_error
      echo output
    endif
    checktime
  endfunction
  nnoremap <silent> <Leader>T :edit tasks<CR>
  nnoremap <silent> <Leader>W :edit job<CR>
  nnoremap <silent> <Leader>s :call <SID>sync_notes()<CR>
endif
