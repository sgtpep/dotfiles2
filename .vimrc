function s:configure_filetypes()
  autocmd BufNewFile,BufRead *.ts,*.tsx setlocal filetype=javascript
  autocmd FileType * call s:define_comment_mappings()
  autocmd FileType css nnoremap <silent> <Leader>a :%!postcss<CR>:update<CR>
  autocmd FileType mail if getline(0, '$') == [''] | startinsert | endif | setlocal formatoptions+=w
endfunction

function s:configure_netrw()
  let g:netrw_banner = 0
  let g:netrw_hide = 1
  let g:netrw_list_hide = '^\./$'
endfunction

function s:define_comment_mappings()
  let [opening, closing] = split(empty(&commentstring) ? '#%s' : &commentstring, '%s', 1)
  execute printf('noremap <buffer> <silent> <Leader>/ :normal 0i%s<C-O>$%s<CR>0', opening, closing)
  execute printf('noremap <buffer> <silent> <Leader>? :normal $%s^%d"_x<CR>', repeat('"_x', strlen(closing)), strlen(opening))
endfunction

function s:define_leader_mappings()
  nnoremap <Leader> <Nop>
  nnoremap <Leader>E :edit %:h/
  nnoremap <Leader>b :buffer<Space><C-D>
  nnoremap <Leader>e :edit<Space>
  nnoremap <Leader>f :find<Space>
  nnoremap <Leader>g :grep<Space>
  nnoremap <silent> <Leader>D :bdelete!<CR>
  nnoremap <silent> <Leader>F :call <SID>update_path()<CR>
  nnoremap <silent> <Leader>N :bnext<CR>
  nnoremap <silent> <Leader>P :bprevious<CR>
  nnoremap <silent> <Leader>R :silent! mkview<CR>:edit!<CR>:silent! loadview<CR>
  nnoremap <silent> <Leader>T :call system(<SID>git() ? 'git ls-files \| xargs -r -d ''\n'' ctags' : 'ctags -R')<CR>
  nnoremap <silent> <Leader>V :let @" = system('xclip -o -selection clipboard')<CR>P
  nnoremap <silent> <Leader>c Vy:call system('xclip -selection clipboard', getreg())<CR>
  nnoremap <silent> <Leader>h :set hlsearch!<CR>
  nnoremap <silent> <Leader>n :cnext<CR>
  nnoremap <silent> <Leader>p :cprevious<CR>
  nnoremap <silent> <Leader>r :call <SID>format_code()<CR>
  nnoremap <silent> <Leader>t :find todo<CR>
  nnoremap <silent> <Leader>v :let @" = system('xclip -o -selection clipboard')<CR>p
  nnoremap <silent> <Leader>w :write<CR>
  nnoremap <silent> <Leader>x Vx:call system('xclip -selection clipboard', getreg())<CR>
  nnoremap <silent> <Leader>y :call system('xclip -selection clipboard', expand('%'))<CR>
  vnoremap <silent> <Leader>c y:call system('xclip -selection clipboard', getreg())<CR>
  vnoremap <silent> <Leader>s :sort<CR>
  vnoremap <silent> <Leader>v :<C-U>let @" = system('xclip -o -selection clipboard')<CR>gvp
  vnoremap <silent> <Leader>x x:call system('xclip -selection clipboard', getreg())<CR>
endfunction

function s:define_mappings()
  nnoremap Q <Nop>
  let g:mapleader = ' '
  call s:define_leader_mappings()
endfunction

function s:enable_filetypes()
  filetype plugin on
  call s:configure_filetypes()
endfunction

function s:format_code()
  let rust = &filetype ==# 'rust'
  let output = systemlist(rust ? 'rustfmt' : printf('PATH=node_modules/.bin:$PATH prettier --cursor-offset=%d --stdin-filepath=%s', abs(line2byte(line('.'))) + col('.') - 2, shellescape(expand('%'))), getline(1, '$'))
  if v:shell_error
    let [output] = rust ? [output] : [output]
    echo join(output, "\n")
    echo get(output, rust ? 1 : 0, '')
    let match = matchlist(get(output, rust ? 1 : 0, ''), rust ? ':\(\d\+\):\(\d\+\)$' : '(\(\d\+\):\(\d\+\))$')
    if len(match)
      call cursor(match[1], match[2])
    endif
  else
    let [offset, output] = rust ? [-1, output] : [output[-1], output[:-2]]
    if output !=# getline(1, '$')
      let view = winsaveview()
      call setline(1, output)
      silent! execute printf('%d,$delete _', len(output) + 1)
      call winrestview(view)
      if offset != -1
        execute 'goto' offset + 1
      endif
    endif
  endif
  write
endfunction

function s:git()
  let path = expand('%:p:h')
  while path != '/'
    if isdirectory(printf('%s/.git', path))
      return 1
    endif
    let path = fnamemodify(path, ':h')
  endwhile
endfunction

function s:main()
  call s:configure_netrw()
  call s:define_mappings()
  call s:enable_filetypes()
  call s:patch_matchparen()
  call s:preserve_view()
  call s:set_options()
  call s:update_path()
endfunction

function s:patch_matchparen()
  let path = expand('~/.vim/plugin/matchparen.vim')
  if !filereadable(path)
    call mkdir(fnamemodify(path, ':h'), 'p')
    call writefile(map(readfile(printf('%s/plugin/%s', $VIMRUNTIME, fnamemodify(path, ':t'))), {_, line -> substitute(line, ' || (&t_Co .*\|\[c_lnum,[^]]*], ', '', '')}), path)
  endif
  highlight MatchParen term=underline
endfunction

function s:preserve_view()
  autocmd BufWinEnter * silent! loadview
  autocmd BufWinLeave * silent! mkview
  set viewdir=/tmp
endfunction

function s:set_options()
  set autoindent
  set directory=/var/tmp//
  set expandtab
  set grepformat=%f:%l:%c:%m
  set grepprg=rg\ --sort=path\ --vimgrep\ --
  set ignorecase
  set noruler
  set nostartofline
  set notitle
  set shiftwidth=2
  set shortmess+=I
  set smartcase
  set smartindent
  set softtabstop=2
  set suffixesadd=.js
  set t_Co=0
  set undodir=/tmp
  set undofile
  set wildignorecase
  set wildmode=list:longest,list:full
  if filereadable('tsconfig.json')
    set suffixes+=.js,.jsx
    set suffixesadd=.ts,.tsx
  endif
endfunction

function s:update_path()
  let &path = join([''] + (s:git() ? uniq(sort(map(systemlist('git ls-files'), {_, path -> path =~ '/' ? substitute(path, '/[^/]*$', '', '') : ''}))) : map(filter(globpath(',', '{.,}*/', 1, 1), {_, path -> path !~# '^\(\.\.\|\.git\|dist\|node_modules\)/$'}), {_, path -> printf('%s**', path)})), ',')
endfunction

call s:main()
