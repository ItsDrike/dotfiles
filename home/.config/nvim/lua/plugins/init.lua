local vim = require("vim")
local packer_m = require("plugins.packer")

-- Require packer_compiled to lazy-load all of the plugins and their settings
-- automatically. If this fails, it means we probably didn't yet compile
-- packer. This file is generated upon running :PackerCompile, so if we didn't
-- find it, we inform the user to run it. We can't run it here directly,
-- because packer may not yet be installed, bootstrapping happens only after
-- this to allow this lazy loadning behavior. If we required packer before
-- this, the lazy-loading would have no effect.
local packer_compiled_ok, _ = pcall(require, "compiled.packer_compiled")
if not packer_compiled_ok then
    vim.notify(
        "Run :PackerCompile or :PackerSync",
        vim.log.levels.WARN,
        { title = "Notification" }
    )
end

-- If packer isn't present, install it automatically it
local present, packer = pcall(require, "packer")

local first_install = false
if not present then
    first_install = packer_m.bootstrap_packer()
    if first_install then
        -- We know this will work now that packer was bootstrapped
        -- Otherwise we'd receive false in first_install
        ---@diagnostic disable-next-line:different-requires
        packer = require("packer")
    end
end

-- Obtain the plugins defined in plugin_list.ua
local plugin_list = require("plugins.plugin_list")
packer_m.startup(packer, plugin_list, first_install)
