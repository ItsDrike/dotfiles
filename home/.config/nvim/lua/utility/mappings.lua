local vim = require("vim")
local api = vim.api
local cmd = vim.cmd

local M = {}

-- Define a keymap
function M.keymap(mode, shortcut, command, options)
    -- Assume silent, noremap unless specified otherwise
    local opts = {noremap=true, silent=true}

    if options then opts = vim.tbl_extend("force", opts, options) end
    api.nvim_set_keymap(mode, shortcut, command, opts)
end

-- Define an abbreviation
function M.abbrev(mode, input, result, reabbrev)
    -- Assume noreabbrev unless specified otherwise
    reabbrev = reabbrev or false
    local command
    if reabbrev then
        command = mode .. "abbrev"
    else
        command = mode .. "noreabbrev"
    end
    cmd(command .. " " .. input .. " " .. result)
end

return M
