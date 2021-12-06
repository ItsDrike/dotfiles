local vim = require("vim")
local cmd = vim.cmd

cmd[[Plug 'tomasiser/vim-code-dark']]

-- Set vim-code-dark as colortheme after plugin loading was finished
cmd[[
augroup VimCodeDark
    autocmd!
    autocmd User PlugLoaded ++nested colorscheme codedark
augroup end
]]
