local vim = require("vim")
local fn = vim.fn

local plugin_directory = fn.stdpath("config") .. "/lua/plugins/settings"

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
    { "airblade/vim-gitgutter" },           -- Git status in files
    { "dhruvasagar/vim-table-mode" },       -- Easy way to construct markdown tables
    { "wakatime/vim-wakatime" },            -- Track time spent coding
    { "mhinz/vim-startify" },               -- Nice startup screen for vim when started withotu file/dir
    { "dbeniamine/cheat.sh-vim" },          -- Quick interaction with cheat.sh cheatsheets
    {
        "vimwiki/vimwiki",                  -- Wiki pages for vim
        config = get_plugin_file("vimwiki.lua"),
    },
    {
        "tpope/vim-commentary",             -- Adds ability to comment out sections of files
        config = get_plugin_file("commentary.lua")
    },
    {
        "tomasiser/vim-code-dark",          -- Vim theme inspired by vscode's Dark+
        config = get_plugin_file("vim-code-dark.lua")
    },
    {
        "nvim-treesitter/nvim-treesitter",  -- AST language analysis providing semantic highlighting
        config = get_plugin_file("treesitter.lua"),
        run = ':TSUpdate',
        requires = { "nvim-treesitter/playground", opt = true }
    },
    {
        "vim-airline/vim-airline",          -- Status line
        config = get_plugin_file("airline.lua"),
        requires = {
            { "vim-airline/vim-airline-themes", opt = true },
            { "ryanoasis/vim-devicons", opt = true },
        },
    },
    {
        "preservim/nerdtree",               -- File tree
        config = get_plugin_file("nerdtree.lua"),
        requires = {
            { "Xuyuanp/nerdtree-git-plugin", opt = true },
            { "tiagofumo/vim-nerdtree-syntax-highlight", opt = true },
            { "ryanoasis/vim-devicons", opt = true },
        },
    },
    {
        "mfussenegger/nvim-dap",            -- Support for the debugging within vim
        config = get_plugin_file("nvim-dap.lua"),
        requires = { "mfussenegger/nvim-dap-python", opt = true },
    },
    {
        "junegunn/fzf.vim",                 -- Fuzzy finder (TODO: consider replacing with telescope)
        run = function() fn['fzf#install']() end,
        config = get_plugin_file("fzf.lua"),
        requires = {
            { "junegunn/fzf", opt = false },
            { "stsewd/fzf-checkout.vim", opt = true },
        }
    },
    {
        'glacambre/firenvim',               -- Integrates neovim into the browser
        config = get_plugin_file("firenvim.lua"),
        run = function() vim.fn['firenvim#install'](0) end
    },
    {
        "williamboman/nvim-lsp-installer",  -- LSP protocol configurations, autocomplete, autoinstaller
        config = get_plugin_file("lsp.lua"),
        requires = {
            "neovim/nvim-lspconfig",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
        },
    },

    -- TODO: Consider testing out telescope as an alternative to FZF, I've heard a lot of
    -- positive feedback about it, but I haven't yet got the chance to meaningfully test
    -- it and configure it.
    --{
    --    "nvim-telescope/telescope.nvim",
    --    --config = get_plugin_file("telescope.lua")
    --    module = "telescope",
    --    cmd = "Telescope",
    --    requires = {
    --        { "nvim-lua/popup.nvim" },
    --        { "nvim-lua/plenary.nvim" },
    --    }
    --},

    -- Coc is disabled because we're using LSP. It implements support from language servers from
    -- scratch, which is slower than neovim's built-in LSP and since this configuration won't work
    -- with pure vim, we can rely on nvim-only thigns. I left it here because LSP can sometimes
    -- cause issues and Coc is a lot more friendly to setup.
    -- {
    --     "neoclide/coc.nvim",
    --     branch = "release",
    --     config = get_plugin_file("coc.vim"),
    --     requires = { "antoinemadec/coc-fzf", opt = true },
    -- },
}

return plugin_list
