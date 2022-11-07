require "user.keys"
require "user.abbreviations"
require "user.lsp"
require "user.autocmds"
require "user.plugins"
require "user.options"
require "user.lualine"
require "user.treesitter"

-- TEMPORARY; Learn vim, the hard way
-- vim.opt.mouse = {}
-- lvim.keys.normal_mode["<Up>"] = ""
-- lvim.keys.normal_mode["<Down>"] = ""
-- lvim.keys.normal_mode["<Left>"] = ""
-- lvim.keys.normal_mode["<Right>"] = ""
-- lvim.keys.visual_mode["<Up>"] = ""
-- lvim.keys.visual_mode["<Down>"] = ""
-- lvim.keys.visual_mode["<Left>"] = ""
-- lvim.keys.visual_mode["<Right>"] = ""
-- lvim.keys.insert_mode["<Up>"] = ""
-- lvim.keys.insert_mode["<Down>"] = ""
-- lvim.keys.insert_mode["<Left>"] = ""
-- lvim.keys.insert_mode["<Right>"] = ""


-- General
lvim.log.level = "warn"
lvim.format_on_save = false
lvim.colorscheme = "onedarker"
-- lvim.colorscheme = "lunar"

-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.dap.active = true
lvim.builtin.terminal.active = true
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.nvimtree.setup.view.side = "left"
--lvim.builtin.project.patterns = { ".git", ".svn" }
lvim.builtin.bufferline.options.always_show_bufferline = true
-- lvim.builtin.nvimtree.setup.renderer.icons.show.git = false
