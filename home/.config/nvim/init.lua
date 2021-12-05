local vim = require("vim")
local fn = vim.fn

-- Define some global functions which can then be called
-- in the other required scripts

-- Load an arbitrary .vim or .lua file
function LoadFile(file_path)
    local extension = file_path:match("^.+(%..+)$")
    local run_cmd
    if (extension == ".vim") then run_cmd = "source" else run_cmd = "luafile" end
    fn.execute(run_cmd .. " " .. file_path)
end

-- Define a key mapping
function Keymap(mode, shortcut, command, options)
    -- Assume silent, noremap unless specified otherwise
    local opts = {noremap=true, silent=true}

    if options then opts = vim.tbl_extend("force", opts, options) end
    vim.api.nvim_set_keymap(mode, shortcut, command, opts)
end

-- Require additional scripts which contain individual configurations

require "base"
require "theme"
require "mappings"
require "abbreviations"
require "autocmd"
require "plugins"
