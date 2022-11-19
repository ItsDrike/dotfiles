-- Autocommands (https://neovim.io/doc/user/autocmd.html)

-- Delete all trailing whitespace on saving
vim.api.nvim_create_autocmd("BufWritePre", { pattern = "*.py", command = [[%s/\s\+$//e]] })
-- Jump to last position when opening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  command = [[if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]],
})
-- Highlight current line number as blue
vim.api.nvim_create_autocmd("ColorScheme", { pattern = "*", command = "highlight CursorLine guibg=#2b2b2b" })
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  command = "highlight CursorLineNr guifg=#1f85de ctermfg=LightBlue",
})
-- Custom syntax definitions based on file extensions
-- vim.api.nvim_create_autocmd("BufRead", { pattern = "*.axml", command = "set ft=xml" })
