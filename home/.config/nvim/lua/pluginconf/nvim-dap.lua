local vim = require("vim")
local cmd = vim.cmd

-- Define dap mappings (:help dap-mapping)
local prefix = ":lua require('dap')."
Keymap("n", "<F5>", prefix .. "continue()<CR>")
Keymap("n", "<F10>", prefix .. "step_over()<CR>")
Keymap("n", "<F11>", prefix .. "step_into()<CR>")
Keymap("n", "<leader><F11>", prefix .. "step_out()<CR>")
Keymap("n", "<F9>", prefix .. "toggle_breakpoint()<CR>")
Keymap("n", "<leader><F9>", prefix .. "set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
Keymap("n", "<F8>", prefix .. "set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>")
Keymap("n", "<leader>di", prefix .. "repl.open()<CR>")
Keymap("n", "<leader>dl", prefix .. "run_last()<CR>")

-- Setup dap for python (requires nvim-dap-python plugin)
require('dap-python').setup('/usr/bin/python')  -- Path to python with `debugpy` library installed
require('dap-python').test_runner = 'pytest'    -- Use pytest to run unit tests

-- Python mappings
local pyprefix = ":lua require('dap-python')."
Keymap("n", "<leader>dptm", pyprefix .. "test_method()<CR>")
Keymap("n", "<leader>dptc", pyprefix .. "test_class()<CR>")
Keymap("v", "<leader>ds", "<ESC>" .. pyprefix .. "debug_selection()<CR>")
