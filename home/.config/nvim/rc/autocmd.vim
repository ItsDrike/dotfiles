" Move ~/.viminfo to XDG_CACHE_HOME
"set viminfofile=$XDG_CACHE_HOME/vim/viminfo

" Disable automatic commenting on newline
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Have Vim jump to the last position when reopening a file
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\""

" Automatically deletes all trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

" Vertically center document when entering insert mode
"autocmd InsertEnter * norm zz

