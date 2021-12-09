local vim = require("vim")
local m = require("utility.mappings")

m.keymap("n", "<A-b>", ":ToggleBlameLine<CR>")

-- Enable blame line automatically
--vim.cmd[[autocmd BufEnter * EnableBlameLine]]

-- Specify the highlight group used for the virtual text ('Comment' by default)
vim.g.blameLineVirtualTextHighlight = 'Question'

-- Don't show a blame line when it isn't yet commited
-- there's no reason to show "Not yet commited" since we have git gutter
vim.g.blameLineMessageWhenNotYetCommited = ''
