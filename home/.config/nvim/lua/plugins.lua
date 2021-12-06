local vim = require("vim")
local cmd = vim.cmd
local api = vim.api
local fn = vim.fn

-- Automatically download (bootstrap) packer plugin manager
-- if it's not already installed
local packer_install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local packer_bootstrap
if fn.empty(fn.glob(packer_install_path)) > 0 then
  print("Installing packer plugin manager, please wait...")
  packer_bootstrap = fn.system({
      'git', 'clone', '--depth', '1',
      'https://github.com/wbthomason/packer.nvim',
      packer_install_path
  })
  print("Packer installed, reload vim to install plugins")
end

-- Automatically run :PackerCompile if plugins.lua is updated
cmd[[
augroup packer_user_config
    autocmd!
    autocmd BufWritePost ~/.config/nvim/lua/plugins.lua source <afile> | PackerCompile
augroup end
]]

-- Returns the line to be executed after plugin is loaded, this
-- is useful for the `config` parameter of packer's use to
-- source `.vim` files or require `.lua` files
-- Expects a file path from pluginconf/ folder
local function get_plugin_file(pluginconf_file)
    local filename, extension = pluginconf_file:match("^(.+)(%..+)$")
    if (extension == ".vim") then
        -- Source wants absolute path
        local pluginconf_path = fn.stdpath("config") .. "lua/pluginconf"
        local source_line = string.format('source "%s/%s"', pluginconf_path, pluginconf_file)
        return string.format("vim.fn.execute('%s')", source_line)
    else
        -- Require wants relative path from lua/
        local pluginconf_path = "pluginconf"
        return string.format('require("%s/%s")', pluginconf_path, filename)
    end
end

-- Make sure to add packer here, even if it's opt
api.nvim_command("packadd packer.nvim")

-- Define packer plugins
return require("packer").startup({
    function(use)
        use("wbthomason/packer.nvim")
        use('airblade/vim-gitgutter')
        use('dhruvasagar/vim-table-mode')
        use('tmhedberg/SimpylFold')
        use('wakatime/vim-wakatime')
        use('mhinz/vim-startify')
        use('ryanoasis/vim-devicons')
        use({
            "tomasiser/vim-code-dark",
            config = get_plugin_file("vim-code-dark.lua"),
        })
        use({
            "vim-airline/vim-airline",
            config = get_plugin_file("airline.lua"),
            requires = { "vim-airline/vim-airline-themes", opt = true },
        })
        use({
            "preservim/nerdtree",
            config = get_plugin_file("nerdtree.lua"),
            requires = {
                { "Xuyuanp/nerdtree-git-plugin", opt = true },
                { "tiagofumo/vim-nerdtree-syntax-highlight", opt = true },
            },
        })
        use({
            "vimwiki/vimwiki",
            config = get_plugin_file("vimwiki.lua")
        })
        use({
            "sheerun/vim-polyglot",
            setup = get_plugin_file("polyglot.lua")
        })
        use({
            "tpope/vim-commentary",
            config = get_plugin_file("commentary.lua")
        })
        use({
            "junegunn/fzf",
            run = function() fn['fzf#install']() end,
        })
        use({
            "junegunn/fzf.vim",
            config = get_plugin_file("fzf.lua"),
            after = "fzf",
            requires = { "stsewd/fzf-checkout.vim", opt = true },
        })
        use({
            "neoclide/coc.nvim",
            branch = "release",
            config = get_plugin_file("coc.vim"),
            requires = { "antoinemadec/coc-fzf", opt = true },
        })

        -- Run sync if we've just bootstrapped packer
        if packer_bootstrap then
            require("packer").sync()
        end
    end,
    config = {
        display = {
            open_fn = require('packer.util').float,
        },
        profile = {
            enable = true,
            threshold = 1, -- the amount in ms that a plugins load time must be over for it to be included in the profile
        },
    }
})
