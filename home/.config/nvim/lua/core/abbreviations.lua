local vim = require("vim")
local fn = vim.fn
local m = require("utility.mappings")

local function cabbrev(input, result, reabbrev)
    m.abbrev("c", input, result, reabbrev)
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
local initlua = fn.stdpath("config") .. "init.lua"
cabbrev("reload", "luafile " .. initlua)
