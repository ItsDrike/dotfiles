-- keymappings (view all the lunarvim keybinds with <leader>Lk or list every mapping with :map)
lvim.leader = "space"

-- Common shortcuts
lvim.keys.normal_mode["<C-s>"] = ":w<CR>"
lvim.keys.insert_mode["<C-s>"] = "<Esc>:w<CR>i"
lvim.keys.normal_mode["<C-z>"] = ":undo<CR>"
lvim.keys.normal_mode["<C-y>"] = ":redo<CR>"

-- Horizontal movements
lvim.keys.normal_mode["H"] = "^"
lvim.keys.normal_mode["L"] = "$"

-- Moving through buffers
lvim.keys.normal_mode["<A-l>"] = ":BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<A-h>"] = ":BufferLineCyclePrev<CR>"
lvim.keys.normal_mode["<A-L>"] = ":BufferLineMoveNext<CR>"
lvim.keys.normal_mode["<A-H>"] = ":BufferLineMovePrev<CR>"

-- Opening various menus
lvim.keys.normal_mode["<C-n>"] = ":NvimTreeFindFileToggle<CR>"
lvim.keys.normal_mode["<C-f>"] = ":Lf<CR>"
lvim.keys.normal_mode["<A-m>"] = ":MinimapToggle<CR>"
lvim.keys.normal_mode["<A-s>"] = ":SymbolsOutline<CR>"

-- Delete to void register
lvim.keys.visual_mode["<A-d>"] = '"_d'
lvim.keys.normal_mode["<A-d>"] = '"_d'
lvim.keys.visual_mode["<A-p>"] = '"_dP'
lvim.keys.visual_mode["p"] = '"_dP'

-- Remove highlight
lvim.keys.normal_mode["<esc><esc>"] = ":nohlsearch<cr>"

-- Debugger
lvim.keys.normal_mode["<F9>"] = ":DapToggleBreakpoint<CR>"
lvim.keys.normal_mode["<F5>"] = ":DapContinue<CR>"
lvim.keys.normal_mode["<F6>"] = ":DapToggleRepl<CR>"
lvim.keys.normal_mode["<S-F5>"] = ":DapTerminate<CR>"
lvim.keys.normal_mode["<F10>"] = ":DapStepOver<CR>"
lvim.keys.normal_mode["<F11>"] = ":DapStepInto<CR>"
lvim.keys.normal_mode["<S-F11>"] = ":DapStepOut<CR>"

-- Quick word replacing (use . for next word)
lvim.keys.normal_mode["cn"] = "*``cgn"
lvim.keys.normal_mode["cN"] = "*``cgN"

lvim.builtin.terminal.open_mapping = "<C-t>"

-- Quick replace all
vim.api.nvim_set_keymap("n", "<A-r>", "", {
  noremap = true,
  callback = function()
    vim.fn.inputsave()
    local query = vim.fn.input "To replace: "

    vim.fn.inputsave()
    local answer = vim.fn.input("Replace text: ", query)
    vim.api.nvim_command("%s/\\V" .. query:gsub("/", "\\/") .. "/" .. answer:gsub("/", "\\/") .. "/")
    vim.fn.inputrestore()
    vim.api.nvim_feedkeys("v", "n", false)
  end,
})
vim.api.nvim_set_keymap("v", "<A-r>", "", {
  noremap = true,
  callback = function()
    local getselection = function()
      return vim.fn.strcharpart(vim.fn.getline(vim.fn.line "."), vim.fn.min {
        vim.fn.charcol ".",
        vim.fn.charcol "v",
      } - 1, vim.fn.abs(vim.fn.charcol "." - vim.fn.charcol "v") + 1)
    end

    local query = getselection()

    vim.fn.inputsave()
    local answer = vim.fn.input("Replace text: ", query)
    vim.api.nvim_command("%s/\\V" .. query:gsub("/", "\\/") .. "/" .. answer:gsub("/", "\\/") .. "/")
    vim.fn.inputrestore()
    vim.api.nvim_feedkeys("v", "n", false)
  end,
})

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
-- local _, actions = pcall(require, "telescope.actions")
-- lvim.builtin.telescope.defaults.mappings = {
--   -- for input mode
--   i = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--     ["<C-n>"] = actions.cycle_history_next,
--     ["<C-p>"] = actions.cycle_history_prev,
--   },
--   -- for normal mode
--   n = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--   },
-- }

-- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble workspace_diagnostics<cr>", "Workspace Diagnostics" },
-- }
