if getcwd() ==# expand('~/notes')
  function s:sync_notes()
    update
    let output = system('online sync-notes')
    if v:shell_error
      echo output
    endif
    checktime
  endfunction
  autocmd BufRead budget nnoremap <silent> <Leader>C :%!limit=500; read -r date amount; printf "\%(\%Y-\%m-\%d)T $((amount + ($(printf '\%(\%s)T') - $(date -d "$date" +\%s)) / (60 * 60 * 24) * limit - ($(paste -s -d +) + 0)))"<CR>
  nnoremap <silent> <Leader>B :edit budget<CR>
  nnoremap <silent> <Leader>T :edit tasks<CR>
  nnoremap <silent> <Leader>W :edit job<CR>
  nnoremap <silent> <Leader>s :call <SID>sync_notes()<CR>
endif
