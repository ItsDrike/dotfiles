vim.api.nvim_create_autocmd("BufWinEnter", { pattern = "*.lua", command = "setlocal shiftwidth=2" })
vim.api.nvim_create_autocmd("BufWinEnter", { pattern = "*.lua", command = "setlocal tabstop=2" })
