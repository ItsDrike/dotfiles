local vim = require("vim")
local cmd = vim.cmd
local api = vim.api
local fn = vim.fn

-- This module contains several functions regarding packer plugin manager
-- Most notably the get_plugin_file and packer_setup fucntions
local M = {}

-- Drectory containing the individual plugin configuration files.
-- File to hold the compiled packer binary
M.packer_compiled_path = fn.stdpath("config") .. "plugin/packer_compiled.lua"

-- Return the line (string) to be executed with lua that loads in given plugin file.
-- This is useful for the `config` or `setup` parameters of packer's use to either
-- source `.vim` files, or require `.lua` files.
-- Expects a `plugin_file` which is a relative path from the `plugin_directory` folder.
function M.get_plugin_file(plugin_file, plugin_directory)
    local filename, extension = plugin_file:match("^(.+)(%..+)$")
    if (extension == ".vim") then
        local source_line = string.format('source "%s/%s"', plugin_directory, plugin_file)
        return string.format("vim.fn.execute('%s')", source_line)
    else
        return string.format('require("%s/%s")', plugin_directory, filename)
    end
end

-- Download packer plugin manager in case it isn't already installed
function M.packer_bootstrap()
    local first_install = false
    local present, packer = pcall(require, "packer")
    if not present then
        local packer_install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
        print("Clonning pakcer plugin manager, please wait...")
        -- First remove the directory in case it already exists but packer isn't present
        fn.delete(packer_install_path, "rf")
        fn.system({
            "git", "clone", "--depth", "1",
            "https://github.com/wbthomason/packer.nvim",
            packer_install_path
        })

        -- Make sure packer was installed properly
        cmd("packadd packer.nvim")
        present, packer = pcall(require, "packer")

        if present then
            print("Packer clonned successfully.")
            first_install = true
        else
            print("Couldn't clone packer! Packer path: " .. packer_install_path .. "\n" .. packer)
        end
    end

    return { present = present, first_install = first_install, packer = packer }
end

-- Initialize packer with our desired configuration
-- If packer isn't instaleld, this also performs the installation
function M.packer_init()
    local details = M.packer_bootstrap()
    -- Only continue if we actually managed to install packer
    if not details.present then
        return details
    end

    details.packer.init({
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
        compile_path = M.packer_compiled_path,
    })

    return details
end

-- Run packer's setup function and define all of the used plugins
-- Expects table/list of tables holding the individual plugin settings
function M.packer_setup(plugin_configs)
    local details = M.packer_init()
    if not details.present then
        return false
    end

    local packer = details.packer
    local use = packer.use
    local first_install = details.first_install

    -- Make sure to add packer here, even if it's opt
    api.nvim_command("packadd packer.nvim")

    return packer.startup(function()
        -- We always want to let packer manage itself
        use("wbthomason/packer.nvim")

        -- Load the obtained plugins (in any)
        if plugin_configs and not vim.tbl_isempty(plugin_configs) then
            for _, plugin in pairs(plugin_configs) do
                use(plugin)
            end
        end

        if first_install then
            packer.sync()
        end
    end)
end

return M
