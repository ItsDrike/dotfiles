" Unmap arrow keys in normal mode to remove bad habits
nnoremap <Down> <nop>
nnoremap <Left> <nop>
nnoremap <Right> <nop>
nnoremap <Up> <nop>

" Stop search highlight on Ctrl+l (until next search)
map <silent> <C-l> :noh<CR>

" System clipboard interactions
map <C-c> "+y
vnoremap <C-v> "+p

" Start spell-check
map <leader>s :setlocal spell! spelllang=en_us<CR>

" Use shift to move 10 lines up/down quickly
noremap <silent> K 10k
noremap <silent> J 10j

" Enable/Disable auto comment
map <leader>c :setlocal formatoptions-=cro<CR>
map <leader>C :setlocal formatoptions=cro<CR>

" Tab navigation
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <silent> <A-t> :tabnew<CR>
nnoremap <silent> <A-2> :tabmove +<CR>
nnoremap <silent> <A-1> :tabmove -<CR>
nnoremap <A-p> :tabp<CR>
nnoremap <A-n> :tabn<CR>

" Remap splits navigation to just CTRL + hjkl
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Make adjusting split sizes a bit more friendly
noremap <silent> <C-Right> :vertical resize +3<CR>
noremap <silent> <C-left> :vertical resize -3<CR>
noremap <silent> <C-Up> :resize +3<CR>
noremap <silent> <C-Down> :resize -3<CR>

" Alias replace all
nnoremap <A-s> :%s//gI<Left><Left><Left>

" Save file as sudo when no write permissions
cmap w!! w !sudo tee > /dev/null %

" Don't leave visual mode after indenting
vmap < <gv
vmap > >gv

" Compile opened file (using custom comp script)
nnoremap <A-c> :w \| !comp <c-r>%<CR>

" Shell check
nnoremap <leader>p :!shellcheck %<CR>
