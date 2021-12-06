local plugins = require("utility.plugins")
local vim = require("vim")
local cmd = vim.cmd
local fn = vim.fn

-- Automatically run :PackerCompile if plugins.lua is updated
cmd[[
augroup packer_user_config
    autocmd!
    autocmd BufWritePost ~/.config/nvim/lua/plugins.lua source <afile> | PackerCompile
augroup end
]]


-- Extend plugins.get_plugin_file function and automatically pass a plugin_directory
-- into it. Expects a relative path to the plugin file settings from this directory
local function plug_cfg(plugin_file)
    local plugin_directory = fn.stdpath("config") .. "lua/pluginconf"
    plugins.get_plugin_file(plugin_file, plugin_directory)
end


-- Define packer plugins
local plugin_configs = {
    { "airblade/vim-gitgutter" },
    { "dhruvasagar/vim-table-mode" },
    { "tmhedberg/SimpylFold" },
    { "wakatime/vim-wakatime" },
    { "mhinz/vim-startify" },
    { "ryanoasis/vim-devicons" },
    { "vimwiki/vimwiki", config = plug_cfg("vimwiki.lua") },
    { "sheerun/vim-polyglot", setup = plug_cfg("polyglot.lua") },
    { "tpope/vim-commentary", config = plug_cfg("commentary.lua") },
    { "junegunn/fzf", run = function() fn['fzf#install']() end },
    { "tomasiser/vim-code-dark", config = plug_cfg("vim-code-dark.lua") },
    {
        "vim-airline/vim-airline",
        config = plug_cfg("airline.lua"),
        requires = { "vim-airline/vim-airline-themes", opt = true },
    },
    {
        "preservim/nerdtree",
        config = plug_cfg("nerdtree.lua"),
        requires = {
            { "Xuyuanp/nerdtree-git-plugin", opt = true },
            { "tiagofumo/vim-nerdtree-syntax-highlight", opt = true },
        },
    },
    {
        "mfussenegger/nvim-dap",
        config = plug_cfg("nvim-dap.lua"),
        requires = { "mfussenegger/nvim-dap-python", opt = true },
    },
    {
        "junegunn/fzf.vim",
        config = plug_cfg("fzf.lua"),
        after = "fzf",
        requires = { "stsewd/fzf-checkout.vim", opt = true },
    },
    {
        "neoclide/coc.nvim",
        branch = "release",
        config = plug_cfg("coc.vim"),
        requires = { "antoinemadec/coc-fzf", opt = true },
    },
}

-- Set up packer and use given plugins
plugins.packer_setup(plugin_configs)
