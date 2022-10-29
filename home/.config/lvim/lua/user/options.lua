-- Show whitespaces
vim.opt.list = true -- Enable showing characters like <Tab>, <EOL>
vim.opt.listchars = { tab = " ", trail = "·" } -- Specify which characters to show

-- Theme options
vim.opt.cursorline = true -- Highlight cursor line
vim.opt.laststatus = 2 -- Always show status line
vim.opt.relativenumber = true -- Use relative line numbers
vim.opt.wrap = true -- Allow line wrapping

-- Tab/Indent settings
-- vim.opt.autoindent = true -- Enable automatic indenting
-- vim.opt.expandtab = true -- Expand tabs into spaces
-- vim.opt.tabstop = 2 -- Number of spaces a tab in file accounts for
-- vim.opt.shiftwidth = 4 -- Indentation size for Tab
-- vim.opt.softtabstop = 4 -- Tabs/Spaces interlop
-- vim.opt.tabpagemax = 50 -- More tabs
-- vim.opt.shiftround = true -- Always round indent to multiple of shiftwidth

-- Enable syntax highlighting in fenced markdown code-blocks
vim.g.markdown_fenced_languages = {"html", "javascript", "typescript", "css", "scss", "lua", "vim", "python"}

-- Other
vim.opt.shell = "/bin/sh"
