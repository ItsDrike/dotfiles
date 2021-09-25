filetype plugin on              " Enable filetype detection

" Tab settings
set expandtab					" Expand tabs to spaces
set tabstop=4					" Tab size
set shiftwidth=4				" Indentation size
set softtabstop=4				" Tabs/Spaces interrop
set tabpagemax=50				" More tabs

" In-file Search (/)
set ignorecase					" Do case insensitive matching
set incsearch					" Show partial matches for a search phrase
set hlsearch					" Highlight Search

" Command-mode search
set path+=**                    " Search down into subfolders with tab completion
set wildmode=longest,list,full	" Enable autocompletion
set wildmenu                    " Display all matching files when we tab complete

" Folding
set foldmethod=indent           " Use indent to determine the fold levels
set foldnestmax=8               " Only fold up to given amount of levels
set foldlevel=2                 " Set initial fold level
set nofoldenable                " Hide all folds by default


" Misc
set autoindent					" Enable autoindent
set autoread					" Reload files on change
set undolevels=999				" Lots of these
set history=1000				" More history
set encoding=utf-8              " Use UTF-8 encoding
set mouse=a				        " Enable mouse mode
set splitbelow splitright		" Split in more natural way

