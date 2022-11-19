vim.api.nvim_create_autocmd("BufWinEnter", { pattern = "*.md", command = "setlocal tw=119" })
vim.api.nvim_create_autocmd("BufWinEnter", { pattern = "*.md", command = "SymbolsOutline" })
