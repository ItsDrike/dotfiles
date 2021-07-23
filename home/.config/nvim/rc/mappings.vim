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

