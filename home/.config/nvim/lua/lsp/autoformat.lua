local vim = require("vim")
local cmd = vim.cmd

-- Always automatically format on write for given filenames
cmd[[autocmd BufWritePre *.js lua vim.lsp.buf.formatting_sync(nil, 100)]]
