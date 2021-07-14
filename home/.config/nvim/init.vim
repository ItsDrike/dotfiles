" Install plugins automatically
if ! filereadable(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim"'))
	echo "Downloading junegunn/vim-plug to manage plugins..."
	silent !mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/
	silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim
	autocmd VimEnter * PlugInstall
endif

" Vim-Plug (Plugins)
call plug#begin(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugged"'))
Plug 'airblade/vim-gitgutter'                                   " Shows Git diff
Plug 'preservim/nerdcommenter'                                  " Language based comment syntax
Plug 'preservim/nerdtree'                                       " File manager (nerdtree)
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'                  " Highlighting for nerdtree
Plug 'joshdick/onedark.vim'				                        " OneDark theme
Plug 'ryanoasis/vim-devicons'                                   " Icons for nerdtree and airline
Plug 'vim-airline/vim-airline'			                        " AirLine statusline
Plug 'vim-airline/vim-airline-themes'	                        " AirLine statusline themes
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }   " Auto-completion [NVIM only]
Plug 'neomake/neomake'					                        " Syntax checking
Plug 'zchee/deoplete-jedi'                                      " Python jedi autocompletion
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
set path+=**                    " Search down into subfolders with tab completion
set wildmenu                    " Display all matching files when we tab complete
set scrolloff=5                 " Keep 5 lines horizontal scrolloff
set sidescrolloff=5             " Keep 5 characters vertical scrolloff
"set termguicolors				" Use true colors (256) (May cause issues on TTY)

" Move ~/.viminfo to XDG_CACHE_HOME
"set viminfofile=$XDG_CACHE_HOME/vim/viminfo

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

" Spell-check set to <leader>o, 'o' for 'orthography'
map <leader>o :setlocal spell! spelllang=en_US<CR>

" Stop search highlight (until next search)
map <silent> <esc> :noh<CR>

" System clipboard interactions
map <C-c> "+y
vnoremap <C-v> "+p

" Unmap arrow keys in normal mode to remove bad habits
nnoremap <Down> <nop>
nnoremap <Left> <nop>
nnoremap <Right> <nop>
nnoremap <Up> <nop>

" Use shift to move 10 lines up/down quickly
noremap <silent> K 10k
noremap <silent> J 10j

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
