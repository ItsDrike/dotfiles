-- Main Hyprland Lua config.
-- Hyprland's Lua require() resolves relative to this file and isolates each
-- required file so one module's runtime error does not stop the others.

require("modules.permissions")
require("modules.keybinds")
require("modules.input")
require("modules.style")
require("modules.window_rules")
require("modules.misc")
require("modules.debug")

-- `exec-once = uwsm finalize` in hyprlang maps to the startup event in Lua.
hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm finalize")
end)
