local vim = require("vim")
local cmd = vim.cmd

-- Set up shortcuts to quickly comment some code
Keymap("n", "<A-/>", ":Commentary<CR>")
Keymap("v", "<A-/>", ":Commentary<CR>")

-- Set up comments for unhandled file types
cmd[[autocmd FileType apache setlocal commentstring=#\ %s]]
