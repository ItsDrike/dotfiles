local vim = require("vim")
local cmd = vim.cmd

-- I'm not aware of abbreviations having direct lua support like mappings,
-- though I'm not certain on that and may be completely wrong, if there is
-- a better way, this is opened to pull requests.
-- TODO: Check direct abbrev lua support

-- Make these function definitions global as they could be reused
-- in plugin specific scripts or in other places.
function abbrev(mode, input, result, reabbrev)
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

function cabbrev(input, result, reabbrev)
    abbrev("c", input, result, reabbrev)
end

-- Invalid case abbreviations
cabbrev("Wq", "wq")
cabbrev("wQ", "wq")
cabbrev("WQ", "wq")
cabbrev("Wa", "wa")
cabbrev("W", "w")
cabbrev("Q", "q")
cabbrev("Qall", "qall")
cabbrev("W!", "w!")
cabbrev("Q!", "q!")
cabbrev("Qall!", "qall!")

-- Save file with sudo
cabbrev("w!!", "w !sudo tee > /dev/null %")

-- Reload lua configuration
-- TODO: Get the path dynamically
cabbrev("reload", "luafile ~/.config/nvim/init.lua")

