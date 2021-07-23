" General colorscheme settings
syntax on                   " Turn syntax highlighting on
colorscheme codedark        " Requires vim-code-dark plugin

set number relativenumber   " Show relative line numbers
set cursorline              " Highlight cursor line
set noruler                 " Don't show ruler, line is highlighted by above

set guioptions-=m           " Remove menubar
set guioptions-=T           " Remove toolbar
set guioptions-=r           " Remove right-hand scrollbar
set guioptions-=L           " Remove left-hand scrollbar

if empty($DISPLAY) " Don't use true colors (256) in TTY
    set notermguicolors
else
    set termguicolors
endif


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

