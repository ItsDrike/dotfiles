local m = require("utility.mappings")
local vim = require("vim")
local g = vim.g


-- This is a bit silly, but I don't like passing the mode argument
g.mapleader = "\\"

-- Unmap arrow keys in normal mode to remove bad habits
m.keymap("n", "<Down>", "<nop>")
m.keymap("n", "<Left>", "<nop>")
m.keymap("n", "<Right>", "<nop>")
m.keymap("n", "<Up>", "<nop>")

-- Tab navigation
m.keymap("n", "<Tab>", "gt")
m.keymap("n", "<S-Tab>", "gT")
m.keymap("n", "<A-t>", ":tabnew<CR>")
m.keymap("n", "<A-2>", ":tabmove +<CR>")
m.keymap("n", "<A-1>", ":tabmove -<CR>")
m.keymap("n", "<A-p>", ":tabp<CR>")
m.keymap("n", "<A-n>", ":tabn<CR>")
m.keymap("n", "<A-c>", ":tabc<CR>")

-- Buffer navigation
m.keymap("n", "<A-N>", ":bn<CR>")
m.keymap("n", "<A-P>", ":bp<CR>")
m.keymap("n", "<A-d>", ":bd<CR>")

-- Set splits navigation to just ALT + hjkl
m.keymap("n", "<C-h>", "<C-w>h")
m.keymap("n", "<C-j>", "<C-w>j")
m.keymap("n", "<C-k>", "<C-w>k")
m.keymap("n", "<C-l>", "<C-w>l")

-- Split size adjusting
m.keymap("n", "<C-Left>", ":vertical resize +3<CR>")
m.keymap("n", "<C-Right>", ":vertical resize -3<CR>")
m.keymap("n", "<C-Up>", ":resize +3<CR>")
m.keymap("n", "<C-Down>", ":resize -3<CR>")

-- Define some common shortcuts
m.keymap("n", "<C-s>", ":w<CR>")
m.keymap("i", "<C-s>", "<Esc>:w<CR>i")
m.keymap("n", "<C-z>", ":undo<CR>")
m.keymap("n", "<C-y>", ":redo<CR>")

-- Terminal
m.keymap("n", "<C-t>", ":split term://zsh<CR>:resize -7<CR>i")
m.keymap("n", "<C-A-t>", ":vnew term://zsh<CR>i")
m.keymap("n", "<A-T>", ":tabnew term://zsh<CR>i")
m.keymap("t", "<Esc>", "<C-\\><C-n>")

-- Use space for folding/unfolding sections
m.keymap("n", "<space>", "za")
m.keymap("v", "<space>", "zf")

-- Use shift to quickly move 10 lines up/down
m.keymap("n", "K", "10k")
m.keymap("n", "J", "10j")

-- Enable/Disable auto commenting
m.keymap("n", "<leader>c", ":setlocal formatoptions-=cro<CR>")
m.keymap("n", "<leader>C", ":setlocal formatoptions+=cro<CR>")

-- Don't leave visual mode after indenting
m.keymap("v", "<", "<gv")
m.keymap("v", ">", ">gv")

-- System clipboard copying
m.keymap("v", "<C-c>", '"+y')

-- Alias replace all
m.keymap("n", "<A-s>", ":%s//gI<Left><Left><Left>", {silent=false})

-- Stop search highlight with Esc
m.keymap("n", "<esc>", ":noh<CR>")

-- Start spell-check
m.keymap("n", "<leader>s", ":setlocal spell! spelllang=en_us<CR>")

-- Run shell check
m.keymap("n", "<leader>p", ":!shellckeck %<CR>")

-- Compile opened file (using custom script)
m.keymap("n", "<A-c>", ":w | !comp <c-r>%<CR>")

-- Close all opened buffers
m.keymap("n", "<leader>Q", ":bufdo bdelete<CR>")

-- Don't set the incredibely annoying mappings that trigger dynamic SQL
-- completion with dbext and keeps on freezing vim whenever pressed with
-- a message saying that dbext plugin isn't installed
-- See :h ft-sql.txt
vim.g.omni_sql_no_default_maps = 1
