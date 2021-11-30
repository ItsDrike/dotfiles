-- This file is here to allow running `local vim = require("vim")`, which
-- avoids the hassle of having to ignore vim as undefined-global for lua
-- language server diagnostics. Another advantage is that it actually allows
-- us to detect the attributes of vim so we will get suggestions.

---@diagnostic disable-next-line:undefined-global
return vim
