" XDG Support
" Avoid using this with root, sudo causes issues with this
if empty($MYVIMRC) | let $MYVIMRC = expand('<sfile>:p') | endif

if empty($XDG_CACHE_HOME)  | let $XDG_CACHE_HOME  = $HOME."/.cache"       | endif
if empty($XDG_CONFIG_HOME) | let $XDG_CONFIG_HOME = $HOME."/.config"      | endif
if empty($XDG_DATA_HOME)   | let $XDG_CONFIG_HOME = $HOME."/.local/share" | endif

set runtimepath^=$XDG_CONFIG_HOME/vim
set runtimepath+=$XDG_DATA_HOME/vim
set runtimepath+=$XDG_CONFIG_HOME/vim/after

set packpath^=$XDG_DATA_HOME/vim,$XDG_CONFIG_HOME/vim
set packpath+=$XDG_CONFIG_HOME/vim/after,$XDG_DATA_HOME/vim/after

let g:netrw_home = $XDG_DATA_HOME."/vim"
call mkdir($XDG_DATA_HOME."/vim/spell", 'p')
set viewdir=$XDG_DATA_HOME/vim/view | call mkdir(&viewdir, 'p')

set backupdir=$XDG_CACHE_HOME/vim/backup | call mkdir(&backupdir, 'p')
set directory=$XDG_CACHE_HOME/vim/swap   | call mkdir(&directory, 'p')
set undodir=$XDG_CACHE_HOME/vim/undo     | call mkdir(&undodir,   'p')

" Install plugins automatically
if ! filereadable(system('echo -n "${HOME}/.config/nvim/autoload/plug.vim"'))
	echo "Downloading junegunn/vim-plug to manage plugins..."
	silent !mkdir -p ~/.local/share/vim/autoload
	silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ~/.local/share/vim/autoload/plug.vim
	autocmd VimEnter * PlugInstall
endif

" Vim-Plug (Plugins)
call plug#begin('~/.local/share/vim/plugged')
Plug 'airblade/vim-gitgutter'                                   " Shows Git diff
Plug 'preservim/nerdcommenter'                                  " Language based comment syntax
Plug 'preservim/nerdtree'                                       " File manager (nerdtree)
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'                  " Highlighting for nerdtree
Plug 'joshdick/onedark.vim'				                        " OneDark theme
Plug 'ryanoasis/vim-devicons'                                   " Icons for nerdtree and airline
Plug 'vim-airline/vim-airline'			                        " AirLine statusline
Plug 'vim-airline/vim-airline-themes'	                        " AirLine statusline themes
Plug 'jiangmiao/auto-pairs'				                        " Quote and bracket completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }   " Auto-completion [NVIM only]
Plug 'neomake/neomake'					                        " Syntax checking
Plug 'zchee/deoplete-jedi'                                      " Python jedi autocompletion
Plug 'davidhalter/jedi-vim'                                     " Python implementation check
Plug 'vim-python/python-syntax'                                 " Autodetect python syntax
Plug 'PotatoesMaster/i3-vim-syntax'                             " Autodetect i3 config syntax
Plug 'wakatime/vim-wakatime'                                    " Wakatime integration for coding stats
call plug#end()

" Some basics
filetype plugin on              " Enable filetype detection
syntax on   					" Turn on syntax highlighting
set number relativenumber       " Show relative line numbers
set wildmode=longest,list,full	" Enable autocompletion
set undolevels=999				" Lots of these
set history=1000				" More history
set expandtab					" Expand tabs to spaces (inverse: noexpandtab)
set tabstop=4					" Tab size
set shiftwidth=4				" Indentation size
set softtabstop=4				" Tabs/Spaces interrop
set tabpagemax=50				" More tabs
set autoindent					" Enable autoindent
set cursorline					" Highlight cursor line
set noruler                     " Don't show ruler, line is highlighted by above
set showmatch					" Show matching brackets
set ignorecase					" Do case insensitive matching
set incsearch					" Show partial matches for a search phrase
set hlsearch					" Highlight Search
set laststatus=2				" Always show status line
set splitbelow splitright		" Split in more natural way
set autoread					" Reload files on change
set mouse=a				        " Enable mouse mode
set encoding=utf-8				" Use UTF-8, not ASCII (May cause issues on TTY)
"set termguicolors				" Use true colors (256) (May cause issues on TTY)

" Disable automatic commenting on newline
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Have Vim jump to the last position when reopening a file
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\""

" Automatically deletes all trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

" Remap splits navigation to just CTRL + hjkl
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Make adjusting split sizes a bit more friendly
noremap <silent> <C-Left> :vertical resize +3<CR>
noremap <silent> <C-Right> :vertical resize -3<CR>
noremap <silent> <C-Up> :resize +3<CR>
noremap <silent> <C-Down> :resize -3<CR>

" System clipboard interactions
map <C-c> "+y
vnoremap <C-v> "+p

" Spell-check set to <leader>o, 'o' for 'orthography'
map <leader>o :setlocal spell! spelllang=en_US<CR>

" User interface / Theme
colorscheme onedark
set guioptions-=m	" remove menubar
set guioptions-=T	" remove toolbar
set guioptions-=r	" remove right-hand scrollbar
set guioptions-=L	" remove left-hand scrollbar

" Airline
let g:airline_theme='onedark'
let g:airline#extensions#tabline#enabled = 1
let g:airline#tabline#formatter = 'unique_tail'
let g:webdevicons_enable_airline_statusline = 0
if empty($DISPLAY) " Automatically apply ASCII only config if we don't have DISPLAY (TTY)
    let g:airline_left_sep = '>' " Alternatively: '►'
    let g:airline_right_sep = '<' " Alternatively: '◄'
    let g:airline_symbols_ascii = 1
    let g:webdevicons_enable_airline_tabline = 0 " don't use symbols from vim-devicons
else
    let g:airline_left_sep = "\uE0B0"
    let g:airline_right_sep = "\uE0B2"
    let g:airline_powerline_fonts = 1 " use nice symbols from powerline fonts
endif

" Neomake
" Requires: pip install flake8
let g:neomake_python_enabled_makers = ['flake8']
let g:neomake_python_flake8_maker = {'args': ['--ignore=E501', '--format=default']}
call neomake#configure#automake('nrwi', 500)

" Deoplete
" Requires: pip install pynvim
let g:deoplete#enable_at_startup = 1

" Jedi-vim
let g:jedi#completions_enabled = 0 " disable completions, since we use deoplete
let g:jedi#use_splits_not_buffers = "right"

" NERDTree
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
