-- The configuration is scattered across multiple files in the lua/ folder
-- We can require the individual configurations from here


-- This loads in the basic nvim configuration that doesn't rely on any
-- plugins. it provides default keymaps, options, theming, autocmds, ...
require "core"

-- This loads packer plugin manager which manages our plugins
-- NOTE: Removing this will NOT disable the plugins, but it will disable
-- automatic packer installation, allowing for the plugins to be deleted
-- manually (from ~/.local/share/nvim/site/pack/packer).
require "plugins"
