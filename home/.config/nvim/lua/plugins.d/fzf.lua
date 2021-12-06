local vim = require("vim")
local cmd = vim.cmd
local g = vim.g

cmd[[Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }]]
cmd[[Plug 'junegunn/fzf.vim']]
cmd[[Plug 'stsewd/fzf-checkout.vim']]

g.fzf_layout = {
    up = '~90%',
    window = {
        width = 0.8,
        height = 0.8,
        yoffset = 0.5,
        offset = 0.5
    }
}

cmd[[let $FZF_DEFAULT_OPTS = '--layout=reverse --info=inline']]

-- Customize the Files command to use ripgrep which respects .gitignore files
cmd[[
command! -bang -nargs=? -complete=dir Files
    \ call fzf#run(fzf#wrap('files', fzf#vim#with_preview({ 'dir': <q-args>, 'sink': 'e', 'source': 'rg --files --hidden' }), <bang>0))
]]

-- Add an AllFiles variation that shows ignored files too
cmd[[
command! -bang -nargs=? -complete=dir AllFiles
    \ call fzf#run(fzf#wrap('allfiles', fzf#vim#with_preview({ 'dir': <q-args>, 'sink': 'e', 'source': 'rg --files --hidden --no-ignore' }), <bang>0))
]]

Keymap("n", "<leader>f", ":Files<CR>")
Keymap("n", "<leader>F", ":AllFiles<CR>")
Keymap("n", "<leader>b", ":Buffers<CR>")
Keymap("n", "<leader>h", ":History<CR>")
Keymap("n", "<leader>r", ":Rg<CR>")
Keymap("n", "<leader>R", ":Rg<space>", { silent = false })
Keymap("n", "<leader>gb", ":GBranches<CR>")
