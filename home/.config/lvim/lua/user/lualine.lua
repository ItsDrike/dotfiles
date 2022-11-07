-- Add location (row:col) to lualine
local components = require "lvim.core.lualine.components"
lvim.builtin.lualine.sections.lualine_z = { components.location }
lvim.builtin.lualine.sections.lualine_y = { components.progress }
