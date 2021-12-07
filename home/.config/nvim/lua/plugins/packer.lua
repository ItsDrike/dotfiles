local vim = require("vim")
local cmd = vim.cmd
local fn = vim.fn

local M = {}

-- Define some paths used in the functions
M.packer_install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
M.packer_compile_path = fn.stdpath("config") .. "/lua/compiled/packer_compiled.lua"

-- Define basic default settings for packer
M.packer_settings = {
    display = {
        open_fn = function()
            return require('packer.util').float({ border = "rounded" })
        end,
        prompt_border = "rounded",
    },
    git = {
        -- Timeout for git clones in seconds
        clone_timeout = 600,
    },
    profile = {
        enable = true,
        -- The time that a pluign's load time must surpass for it to be included
        -- in the profile (in miliseconds)
        threshold = 1,
    },
    compile_path = M.packer_compile_path,
    auto_clean = true,
    compile_on_sync = true
}

-- Define default plugins which should always be used
M.default_plugin_list = {
    -- Let packer manager itself, so that it gets updates
    { "wbthomason/packer.nvim" },

    -- Add plugin for speeding up `require` in lua by caching
    --{ "lewis6991/impatient.nvim" },

    -- Replaces default filetype.vim sourced on startup, which includes
    -- 800+ autocommands setting the filetype based on the filename. This
    -- is very slow and this plugin merges them into single autocommand,
    -- which is 175x faster, improving startup time
    --{ "nathom/filetype.nvim" },
}

-- Download and load packer plugin manager
function M.bootstrap_packer()
    print("Clonning pakcer plugin manager, please wait...")
    -- First remove the directory in case it already exists but packer isn't present
    fn.delete(M.packer_install_path, "rf")
    fn.system({
        "git", "clone", "--depth", "1",
        "https://github.com/wbthomason/packer.nvim",
        M.packer_install_path
    })

    -- Add packer plugin via nvim's internal plugin system
    -- and make sure that we can now require it.
    cmd("packadd packer.nvim")
    local present, packer = pcall(require, "packer")
    if present then
        print("Packer clonned successfully.")
        return true
    else
        print("Couldn't clone packer! Packer path: " .. M.packer_install_path .. "\n" .. packer)
        return false
    end
end

-- Run packer startup with the default config and given plugin settings
-- Expects: `packer`, `plugin_list`, `run_sync`, `settings_override`
function M.startup(packer, plugin_list, run_sync, settings_override)
    -- Initialize packer with default settings extended by
    -- the given settings override
    local settings = M.packer_settings
    if settings_override then
        settings = vim.tbl_extend("foce", settings, settings_override)
    end
    packer.reset()
    packer.init(settings)

    -- Run packer startup and use all given plugins with their settings
    -- including the default plugins
    local use = packer.use
    return packer.startup(function()
        -- Use the default plugins (should be first)
        for _, plugin_settings in pairs(M.default_plugin_list) do
            use(plugin_settings)
        end

        -- Use the obtained plugins
        if plugin_list and not vim.tbl_isempty(plugin_list) then
            for _, plugin_settings in pairs(plugin_list) do
                use(plugin_settings)
            end
        end

        -- We can also automatically run sync to install all specified plugins
        -- immediately, this is useful if we've just bootstrapped packer.
        if run_sync then
            vim.notify(
                "Make sure to restart after packer sync!",
                vim.log.levels.WARN,
                { title = "Notification" }
            )
            packer.sync()
        end
    end)
end

return M
