if getcwd() ==# expand('~/notes')
  function s:sync_notes()
    update
    let output = system('execute-online sync-notes')
    if v:shell_error
      echo output
    endif
    checktime
  endfunction
  nnoremap <Leader>T :find tasks<CR>
  nnoremap <Leader>W :find job<CR>
  nnoremap <silent> <Leader>s :call <SID>sync_notes()<CR>
endif
