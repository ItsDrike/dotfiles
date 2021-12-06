local vim = require("vim")
local cmd = vim.cmd

cmd[[Plug 'tpope/vim-commentary']]

Keymap("n", "<A-/>", ":Commentary<CR>")
Keymap("v", "<A-/>", ":Commentary<CR>")

cmd[[autocmd FileType apache setlocal commentstring=#\ %s]]
