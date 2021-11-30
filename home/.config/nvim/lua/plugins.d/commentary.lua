local vim = require("vim")
local cmd = vim.cmd

cmd[[Plug 'tpope/vim-commentary']]

nmap("<A-/>", ":Commentary<CR>")
vmap("<A-/>", ":Commentary<CR>")

cmd[[autocmd FileType apache setlocal commentstring=#\ %s]]
