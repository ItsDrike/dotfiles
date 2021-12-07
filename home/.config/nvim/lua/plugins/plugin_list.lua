local vim = require("vim")
local fn = vim.fn

local plugin_directory = fn.stdpath("config") .. "/lua/pluginconf"

-- Return the line (string) to be executed with lua that loads in given plugin file.
-- This is useful for the `config` or `setup` parameters of packer's use to source
-- both `.vim` and `.lua` files.
-- Expects a `plugin_file` which is a relative path from the `plugin_directory` folder.
local function get_plugin_file(plugin_file)
    local source_line = string.format('source %s/%s', plugin_directory, plugin_file)
    return string.format("vim.fn.execute('%s')", source_line)
end


-- Define packer plugins
-- The individual tables will get passed into the packer's use function
local plugin_list = {
    { "airblade/vim-gitgutter" },
    { "dhruvasagar/vim-table-mode" },
    { "tmhedberg/SimpylFold" },
    { "wakatime/vim-wakatime" },
    { "mhinz/vim-startify" },
    { "ryanoasis/vim-devicons" },
    { "sheerun/vim-polyglot", setup = get_plugin_file("polyglot.lua") },
    { "vimwiki/vimwiki", config = get_plugin_file("vimwiki.lua") },
    { "tpope/vim-commentary", config = get_plugin_file("commentary.lua") },
    { "junegunn/fzf", run = function() fn['fzf#install']() end },
    { "tomasiser/vim-code-dark", config = get_plugin_file("vim-code-dark.lua") },
    {
        "vim-airline/vim-airline",
        config = get_plugin_file("airline.lua"),
        requires = { "vim-airline/vim-airline-themes", opt = true },
    },
    {
        "preservim/nerdtree",
        config = get_plugin_file("nerdtree.lua"),
        requires = {
            { "Xuyuanp/nerdtree-git-plugin", opt = true },
            { "tiagofumo/vim-nerdtree-syntax-highlight", opt = true },
        },
    },
    {
        "mfussenegger/nvim-dap",
        config = get_plugin_file("nvim-dap.lua"),
        requires = { "mfussenegger/nvim-dap-python", opt = true },
    },
    {
        "junegunn/fzf.vim",
        config = get_plugin_file("fzf.lua"),
        after = "fzf",
        requires = { "stsewd/fzf-checkout.vim", opt = true },
    },
    {
        "neoclide/coc.nvim",
        branch = "release",
        config = get_plugin_file("coc.vim"),
        requires = { "antoinemadec/coc-fzf", opt = true },
    },
}

return plugin_list
