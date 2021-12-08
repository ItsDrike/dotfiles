local vim = require("vim")
local cmd = vim.cmd
local g = vim.g

-- Detect filetype based on filename for certain websites
cmd[[
autocmd BufEnter github.com_*.txt set filetype=markdown
autocmd BufEnter txti.es_*.txt set filetype=typescript
]]

-- Define firenvim configuration
g.firenvim_config = {
    globalSettings = { alt="all" },
    localSettings = {
        [".*"] = {
            cmdline = "neovim",
            content = "text",
            priority = 0,
            selector = "textarea",
            -- Don't automatically take over, require the shortcut
            takeover = "never",
        },
        -- Enable automatic takeover on certain websites where it makes sense
        ["https?://github.com"] = { takeover = "always", priority=1 },
        ["https?://txti.es"] = { takeover = "always", priority = 1 },
    }
}
