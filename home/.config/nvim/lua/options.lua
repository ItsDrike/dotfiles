local vim = require("vim")
local cmd = vim.cmd
local o = vim.opt

cmd[[filetype plugin on]]

-- Tab/Indent settings
o.autoindent = true         -- Enable autoindent
o.expandtab = true          -- Expand tabs to spaces
o.tabstop = 4               -- Tab size in spaces
o.shiftwidth = 4            -- Indentation size
o.softtabstop = 4           -- Tabs/Spaces interlop
o.tabpagemax = 50           -- More tabs
o.shiftround = true         -- Always round indent to multiple of shiftwidth

-- Folding
o.foldmethod = "indent"     -- Use indent to determine the fold levels
o.foldnestmax = 8           -- Only fold up to given amount of levels
o.foldlevel = 2             -- Set initial fold level
o.foldenable = false        -- Hide all folds by default

-- Split order
o.splitbelow = true         -- Put new windows below current
o.splitright = true         -- Put new vertical splits to right

-- In-file search (/)
o.ignorecase = true         -- Use case insensitive matching
o.incsearch = true          -- Show partial matches while typing
o.hlsearch = true           -- Highlight search matches

-- Show whitespace
o.list = true                               -- Enable showing characters like <Tab>, <EOL>, ...
o.listchars = {tab = " ", trail = "·"}     -- Specify which characters to show

-- Command-mode search
o.wildmode = {"longest", "list", "full"}    -- Enable autocompletion
o.wildmenu = true                           -- Display all matching files when we tab complete
table.insert(o.path, "**")                  -- Search down into subfolders with tab completion

-- Files
o.encoding = "utf-8"        -- Use UTF-8 encoding
o.autoread = true           -- Automatically reload files on change

-- Misc
o.mouse = "a"               -- Enable mouse mode
o.undolevels = 999          -- Lots of these
o.history = 1000            -- More history
