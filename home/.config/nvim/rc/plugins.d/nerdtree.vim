" NERDTree config
map <C-n> :NERDTreeToggle<CR>
let g:NERDTreeDirArrowExpandable = '►'
let g:NERDTreeDirArrowCollapsible = '▼'
let NERDTreeShowLineNumbers=1
let NERDTreeShowHidden=1
let NERDTreeMinimalUI = 1
let g:NERDTreeWinSize=38
if empty($DISPLAY) " Disable devicons for nerdtree in TTY
    let g:webdevicons_enable_nerdtree = 0
endif

