local vim = require("vim")
local g = vim.g

-- Disable polyglot's "sensible" settings, while there are some nice things it
-- does, I set these manually in my default config and I don't like depending
-- on single plugin for so many things, doing it manually doing it manually is
-- also more explicit making it obvious what's happening
g.polyglot_disabled = {'sensible'}
