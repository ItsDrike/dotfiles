local m = require("utility.mappings")
local vim = require("vim")
local cmd = vim.cmd

-- Define dap mappings (:help dap-mapping)
local prefix = ":lua require('dap')."
m.keymap("n", "<F5>", prefix .. "continue()<CR>")
m.keymap("n", "<F10>", prefix .. "step_over()<CR>")
m.keymap("n", "<F11>", prefix .. "step_into()<CR>")
m.keymap("n", "<leader><F11>", prefix .. "step_out()<CR>")
m.keymap("n", "<F9>", prefix .. "toggle_breakpoint()<CR>")
m.keymap("n", "<leader><F9>", prefix .. "set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
m.keymap("n", "<F8>", prefix .. "set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>")
m.keymap("n", "<leader>di", prefix .. "repl.open()<CR>")
m.keymap("n", "<leader>dl", prefix .. "run_last()<CR>")

-- Setup dap for python (requires nvim-dap-python plugin)
require('dap-python').setup('/usr/bin/python')  -- Path to python with `debugpy` library installed
require('dap-python').test_runner = 'pytest'    -- Use pytest to run unit tests

-- Python mappings
local pyprefix = ":lua require('dap-python')."
m.keymap("n", "<leader>dptm", pyprefix .. "test_method()<CR>")
m.keymap("n", "<leader>dptc", pyprefix .. "test_class()<CR>")
m.keymap("v", "<leader>ds", "<ESC>" .. pyprefix .. "debug_selection()<CR>")
