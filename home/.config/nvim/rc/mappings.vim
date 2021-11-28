" Unmap arrow keys in normal mode to remove bad habits
nnoremap <Down> <nop>
nnoremap <Left> <nop>
nnoremap <Right> <nop>
nnoremap <Up> <nop>

" Tab navigation
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <silent> <A-t> :tabnew<CR>
nnoremap <silent> <A-2> :tabmove +<CR>
nnoremap <silent> <A-1> :tabmove -<CR>
nnoremap <A-p> :tabp<CR>
nnoremap <A-n> :tabn<CR>

" Splits navigation to just ALT + hjkl
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

" Make adjusting split sizes a bit more friendly
noremap <silent> <C-Right> :vertical resize +3<CR>
noremap <silent> <C-left> :vertical resize -3<CR>
noremap <silent> <C-Up> :resize +3<CR>
noremap <silent> <C-Down> :resize -3<CR>

" System clipboard interactions
map <C-c> "+y
vnoremap <C-v> "+p

" Use more common Undo/Redo shortcuts
nnoremap <C-z> :undo<CR>
nnoremap <C-y> :redo<CR>

" Use more common save shortcut
nnoremap <C-s> :w<CR>

" Terminal
nnoremap <C-l> :vnew term://zsh<CR>i
nnoremap <C-t> :split term://zsh<CR>i
nnoremap <A-S-t> :tabnew term://zsh<CR>i

" Alias replace all
nnoremap <A-s> :%s//gI<Left><Left><Left>

" Start spell-check
map <leader>s :setlocal spell! spelllang=en_us<CR>

" Use space for folding/unfolding sections
nnoremap <space> za
vnoremap <space> zf

" Use shift to move 10 lines up/down quickly
noremap <silent> K 10k
noremap <silent> J 10j

" Save file as sudo when no write permissions
cmap w!! w !sudo tee > /dev/null %

" Stop search highlight with Esc in normal mode (until next search)
nnoremap <silent> <esc> :noh<CR>

" Enable/Disable auto comment
map <leader>c :setlocal formatoptions-=cro<CR>
map <leader>C :setlocal formatoptions=cro<CR>

" Don't leave visual mode after indenting
vmap < <gv
vmap > >gv

" Compile opened file (using custom comp script)
nnoremap <A-c> :w \| !comp <c-r>%<CR>

" Shell check
nnoremap <leader>p :!shellcheck %<CR>

" Redefine the incredibely annoying mappings that trigger
" dynamic SQL completion with dbext and keeps on freezing
" vim whenever pressed with a message saying that
" dbext plugin isn't installed...
" See :h ft-sql.txt
let g:omni_sql_no_default_maps = 1

