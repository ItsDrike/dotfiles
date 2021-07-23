" Unmap arrow keys in normal mode to remove bad habits
nnoremap <Down> <nop>
nnoremap <Left> <nop>
nnoremap <Right> <nop>
nnoremap <Up> <nop>

" Stop search highlight on esc (until next search)
map <silent> <esc> :noh<CR>

" System clipboard interactions
map <C-c> "+y
vnoremap <C-v> "+p

" Spell-check set to <leader>o, 'o' for 'orthography'
map <leader>o :setlocal spell! spelllang=en_US<CR>

" Use shift to move 10 lines up/down quickly
noremap <silent> K 10k
noremap <silent> J 10j

" Tab navigation
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <silent> <A-t> :tabnew<CR>
nnoremap <silent> <A-2> :tabmove +<CR>
nnoremap <silent> <A-1> :tabmove -<CR>
nnoremap <A-p> :tabp<CR>
nnoremap <A-n> :tabn<CR>

" Alias replace all
nnoremap <A-s> :%s//gI<Left><Left><Left>

" Save file as sudo when no write permissions
cmap w!! w !sudo tee > /dev/null %

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

