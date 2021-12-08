local m = require("utility.mappings")

-- See `:help vim.lsp.*` for documentation on any of the below mapped functions

-- Check if certain plugins are installed, if so, they should be used
-- to define some mappings
local telescope_installed, _ = pcall(require, "telescope")
local lsp_signature_installed, _ = pcall(require, "lsp_signature")

-- Lookups
m.keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
m.keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
m.keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
m.keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
m.keymap("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")

if telescope_installed then
    m.keymap('n', 'gd', '<cmd>lua require("telescope.builtin").lsp_definitions()<cr>')
    m.keymap('n', 'gr', '<cmd>lua require("telescope.builtin").lsp_references()<cr>')
    m.keymap('n', 'gi', '<cmd>lua require("telescope.builtin").lsp_implementations()<cr>')
    m.keymap('n', 'gt', '<cmd>lua require("telescope.builtin").lsp_type_definitions()<cr>')
end

-- Formatting
m.keymap('n', '<leader>gf', '<cmd>lua vim.lsp.buf.formatting()<cr>')
m.keymap('v', '<leader>gf', '<cmd>lua vim.lsp.buf.range_formatting()<cr>')

-- Hover info
m.keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
m.keymap("n", "M", "<cmd>lua vim.lsp.buf.hover()<CR>")

if lsp_signature_installed then
    m.keymap('n', '<C-M>', '<cmd>lua require("lsp_signature").signature()<cr>')
end

-- Diagnostics
m.keymap('n', '[g', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
m.keymap('n', ']g', '<cmd>lua vim.diagnostic.goto_next()<cr>')
m.keymap('n', 'ge', '<cmd>lua vim.diagnostic.open_float(nil, { scope = "line", })<cr>')

if telescope_installed then
    m.keymap('n', '<leader>ge', '<cmd>lua require("telescope.builtin").lsp_document_diagnostics()<cr>')
end

-- LSP Workspace
m.keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>')
m.keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>')
m.keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>')

--Actions
if telescope_installed then
    m.keymap('n', '<leader>ga', '<cmd>lua require("telescope.builtin").lsp_code_actions()<cr>')
    m.keymap('v', '<leader>ga', '<cmd>lua require("telescope.builtin").lsp_range_code_actions()<cr>')
end

-- Use custom implementation for renaming all references
m.keymap('n', 'gn', '<cmd>lua require("lsp/rename").rename()<cr>')
