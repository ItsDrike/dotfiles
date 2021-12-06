local vim = require("vim")
local cmd = vim.cmd
local o = vim.opt

cmd[[syntax on]]                -- Turn on syntax highlighting

o.cursorline = true             -- Highlight cursor line
o.laststatus = 2                -- Always show status line
o.number = true                 -- Show line numbers
o.relativenumber = true         -- Use relative line numbers
o.showmatch = true              -- Show matching bracket
o.scrolloff = 5                 -- Keep 5 lines horizontal scrolloff
o.sidescrolloff = 5             -- Keep 5 chars vertical scrolloff
o.showmode = false              -- Don't display mode (it's on status line anyway)

-- I wasn't able to find a way to set guioptions directly in lua
cmd[[
set guioptions-=m       " Remove menubar
set guioptions-=T       " Remove toolbar
set guioptions-=r       " Remove right-hand scrollbar
set guioptions-=L       " Remove left-hand scrollbar
]]

-- Override some colorscheme colors
--  * Use more noticable cursor line color
cmd[[
augroup coloroverride
    autocmd!
    autocmd ColorScheme * highlight CursorLine guibg=#2b2b2b
    autocmd ColorScheme * highlight CursorLineNr guifg=#1F85DE ctermfg=LightBlue
augroup END
]]

-- Don't use true colors in TTY
o.termguicolors = os.getenv("DISPLAY") and true or false
