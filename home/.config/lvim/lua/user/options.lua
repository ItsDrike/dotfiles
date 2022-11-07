-- Show whitespaces
vim.opt.list = true -- Enable showing characters like <Tab>, <EOL>
vim.opt.listchars = { tab = " ", trail = "·" } -- Specify which characters to show

-- Theme options
vim.opt.cursorline = true -- Highlight cursor line
-- vim.opt.laststatus = 2 -- Always show status line
vim.opt.relativenumber = true -- Use relative line numbers
vim.opt.wrap = true -- Allow line wrapping

-- Tab/Indent settings
-- vim.opt.autoindent = true -- Enable automatic indenting
-- vim.opt.expandtab = true -- Expand tabs into spaces
-- vim.opt.tabstop = 2 -- Number of spaces a tab in file accounts for
-- vim.opt.shiftwidth = 4 -- Visual number of spaces inserted for each indentation
-- vim.opt.softtabstop = 4 -- Tabs/Spaces interlop
-- vim.opt.tabpagemax = 50 -- More tabs
-- vim.opt.shiftround = true -- Always round indent to multiple of shiftwidth
--
-- Enable syntax highlighting in fenced markdown code-blocks
vim.g.markdown_fenced_languages = {"html", "javascript", "typescript", "css", "scss", "lua", "vim", "python"}

-- Make vim transparent (removes background)
-- lvim.transparent_window = true

-- Configure formatoption
lvim.autocommands._formatoptions = {}
vim.opt.formatoptions = {
  -- default: tcqj
  t = true, -- Auto-wrap text using 'textwidth'
  c = true, -- Auto-wrap comments using 'textwidth', inserting the comment leader automatically
  r = false, -- Automatically insert the comment leader after hitting <Enter> in Insert mode
  o = false, -- Automatically insert the comment leader after hitting 'o' or 'O' in Normal mode
  q = true, -- Allow formatting of comments with "gq" (won't change blank lines)
  w = false, -- Trailing whitespace continues paragraph in the next line, non-whitespace ends it
  a = false, -- Automatic formatting of paragraph. Every time text is inserted/deleted, paragraph gets reformatted
  n = false, -- Recognize numbered lists when wrapping.
  ["2"] = true, -- Use indent from 2nd line of a paragraph
  v = false, -- Only break a line at a blank entered during current insert command
  b = false, -- Like 'v', but only wrap on entering blank, or before the wrap margin
  l = false, -- Long lines are not broken in insert mode
  m = false, -- Also break at a multibyte character above 255
  M = false, -- When joining lines, don't insert a space before, or after two multibyte chars (overruled by 'B')
  B = false, -- When joining lines, don't insert a space between two multibyte chars (overruled by 'M')
  ["1"] = true, -- Break line before a single-letter word.
  ["]"] = false, -- Respect 'textwidth' rigorously, no line can be longer unless there's some except rule
  j = true, -- Remove comment leader when joining lines, when it makes sense
  p = false, -- Don't break lines at single spaces that follow periods (such as for Surely you're joking, Mr. Feynman!)
}

-- Other
vim.opt.shell = "/bin/sh"
