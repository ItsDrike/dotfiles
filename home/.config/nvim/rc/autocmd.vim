" Move ~/.viminfo to XDG_CACHE_HOME
"set viminfofile=$XDG_CACHE_HOME/vim/viminfo

" Disable automatic commenting on newline
autocmd FileType * setlocal formatoptions-=cro

" Have Vim jump to the last position when reopening a file
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Automatically deletes all trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

" Enable spellcheck for certain file types
autocmd FileType tex,latex,markdown,gitcommit setlocal spell spelllang=en_us

" Use automatic text wrapping at 119 characters for certain file types
autocmd FileType markdown setlocal textwidth=119
