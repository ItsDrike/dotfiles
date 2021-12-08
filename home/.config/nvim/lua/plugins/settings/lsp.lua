local vim = require("vim")
local fn = vim.fn

-- Load in our default plugin independant LSP settings.
-- These are loaded from here, because we don't need them if we aren't using
-- these plugins, which actually load in the LSP configurations and install the
-- individual language servers. However it is possible to configure nvim
-- without these plugins and so this config is separated from the plugin
-- config. for more info, check the comments in lsp/init.lua
require("lsp")


-- Load in the needed settigns for nvim-lsp-installer plugin.
-- This ensures automatic installation for the individual language servers.
local lsp_installer = require("nvim-lsp-installer")

-- Define some settings for the UI and installation path for the language
-- servers.
lsp_installer.settings({
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        },
        keymaps = {
            toggle_server_expand = "<CR>",
            install_server = "i",
            update_server = "u",
            uninstall_server = "X",
        },
    },
    install_root_dir = fn.stdpath("data") ..  "/lsp_servers",
})

-- Define a table of requested language servers which should be automatically
-- installed.
--
-- NOTE: pylsp requires external installaion with
-- :PylspInstall pyls-flake8 pyls-mypy pyls-isort
local requested_servers = {
    "clangd", "cmake", "omnisharp",
    "cssls", "dockerls", "gopls", "html",
    "hls", "jsonls", "jdtls", "tsserver",
    "sumneko_lua", "pyright", "pylsp",
    "sqlls", "vimls", "yamlls"
}

-- Go through the requested servers and ensure installation
-- Once the servers are ready, run setup() on them. This setup is basically
-- running the lspconfig.server.setup() which means lspconfig is needed to do
-- this.
local lsp_installer_servers = require('nvim-lsp-installer.servers')
for _, requested_server in pairs(requested_servers) do
    local server_available, server = lsp_installer_servers.get_server(requested_server)
    if server_available then
        -- Setup the server once it will become ready
        server:on_ready(function()
            local opts = {}
            server:setup(opts)
        end)
        -- If the server isn't yet installed, schedule the installation
        if not server:is_installed() then
            server:install()
        end
    else
        vim.notify(
            "Can't install: Language server " .. server .. " was not found - SKIPPED",
            vim.log.levels.WARN,
            { title = "Notification" }
        )
    end
end
