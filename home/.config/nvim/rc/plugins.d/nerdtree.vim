" NERDTree config
map <C-n> :NERDTreeToggle<CR>
let g:NERDTreeDirArrowExpandable = '►'
let g:NERDTreeDirArrowCollapsible = '▼'
let NERDTreeShowLineNumbers=1
let NERDTreeShowHidden=1
let NERDTreeMinimalUI = 1
let g:NERDTreeWinSize=25
if empty($DISPLAY) " Disable devicons for nerdtree in TTY
    let g:webdevicons_enable_nerdtree = 0
endif

" If a directory is specified, start NERDTree and move the cursor to its window.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] |
    \ endif

" If a file is specified, start NERDTree and keep the cursor in file window.
"autocmd VimEnter *  if argc() > 0 && !isdirectory(argv()[0]) || exists("s:std_in") |
"    \ execute 'NERDTree' fnamemodify(argv()[0], ':p:h') | wincmd p | endif

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

" If another buffer tries to replace NerdTree, put it in another window, and bring back NerdTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

" Use $NERDTREE_BOOKMARKS environment variable for the location of .NERDTreeBookmarks file
if ! empty($NERDTREE_BOOKMARKS)
    if ! filereadable($NERDTREE_BOOKMARKS)
        let dir = system('dirname $NERDTREE_BOOKMARKS')
        let x = system('mkdir -p ' . dir)
        let x = system('touch $NERDTREE_BOOKMARKS')
    endif
    let g:NERDTreeBookmarksFile = $NERDTREE_BOOKMARKS
endif
