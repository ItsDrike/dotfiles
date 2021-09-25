" Airline specific theming settings
let g:airline_theme='codedark'                  " Use codedark theme from vim-ariline-themes
let g:airline_right_sep = ""                    " Don't use special separators (<)
let g:airline_left_sep = ""                     " Don't use special separators (>)
let g:airline#extensions#tabline#enabled = 1    " Enable tabline (top line)
let g:airline#tabline#formatter = 'unique_tail' " Tabline filename formatter
let g:webdevicons_enable_airline_statusline = 0 " Use special icons from vim-devicons (requires nerdfonts)
let g:airline_powerline_fonts = 1               " Use special symbols from powerline fonts (line no, col no)

if empty($DISPLAY) " Use ASCII-only if we're in TTY
    let g:airline_symbols_ascii = 1
endif

" Disable airline in nerdtree buffer
"augroup filetype_nerdtree
"    au!
"    au FileType nerdtree call s:disable_airline_on_nerdtree()
"    au WinEnter,BufWinEnter,TabEnter * call s:disable_airline_on_nerdtree()
"augroup END
"
"fu s:disable_airline_on_nerdtree() abort
"    let nerdtree_winnr = index(map(range(1, winnr('$')), {_,v -> getbufvar(winbufnr(v), '&ft')}), 'nerdtree') + 1
"    call timer_start(0, {-> nerdtree_winnr && setwinvar(nerdtree_winnr, '&stl', '%#Normal#')})
"endfu
