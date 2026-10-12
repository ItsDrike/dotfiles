-- Main Hyprland Lua configuration. Keep this file as the ordered module entry
-- point; Hyprland isolates each require() call so a runtime error in one
-- module does not prevent the rest of the configuration from loading

require("./hyprland/session")
require("./hyprland/monitors")
require("./hyprland/permissions")
require("./hyprland/input")
require("./hyprland/layout")
require("./hyprland/style/appearance")
require("./hyprland/style/animations")
require("./hyprland/style/fullscreen")
require("./hyprland/behavior")
require("./hyprland/keybinds")
