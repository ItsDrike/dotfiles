local m = require("utility.mappings")
local vim = require("vim")
local cmd = vim.cmd
local g = vim.g

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

m.keymap("n", "<leader>f", ":Files<CR>")
m.keymap("n", "<leader>F", ":AllFiles<CR>")
m.keymap("n", "<leader>b", ":Buffers<CR>")
m.keymap("n", "<leader>h", ":History<CR>")
m.keymap("n", "<leader>r", ":Rg<CR>")
m.keymap("n", "<leader>R", ":Rg<space>", { silent = false })
m.keymap("n", "<leader>gb", ":GBranches<CR>")
