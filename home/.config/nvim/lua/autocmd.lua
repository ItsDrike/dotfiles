local vim = require("vim")
local cmd = vim.cmd

-- Disable automatic commenting on newlines
cmd[[autocmd FileType * setlocal formatoptions-=cro]]

-- Have vim jump to last position when reopening a file
cmd[[autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]]

-- Automatically delete all trailing whitespace on save
cmd[[autocmd BufWritePre * %s/\s\+$//e]]

-- Enable spellcheck for certain file types
cmd[[autocmd FileType tex,latex,markdown,gitcommit setlocal spell spelllang=en_us]]

-- Use auto-wrap for certain file types at 119 chars
cmd[[autocmd FileType markdown setlocal textwidth=119]]

-- Don't show line numbers in terminal
cmd[[autocmd BufEnter term://* setlocal nonumber | setlocal norelativenumber]]

