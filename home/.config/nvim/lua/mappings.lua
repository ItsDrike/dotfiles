local vim = require("vim")
local g = vim.g


-- This is a bit silly, but I don't like passing the mode argument
g.mapleader = "\\"

-- Unmap arrow keys in normal mode to remove bad habits
Keymap("n", "<Down>", "<nop>")
Keymap("n", "<Left>", "<nop>")
Keymap("n", "<Right>", "<nop>")
Keymap("n", "<Up>", "<nop>")

-- Tab navigation
Keymap("n", "<Tab>", "gt")
Keymap("n", "<S-Tab>", "gT")
Keymap("n", "<A-t>", ":tabnew<CR>")
Keymap("n", "<A-2>", ":tabmove +<CR>")
Keymap("n", "<A-1>", ":tabmove -<CR>")
Keymap("n", "<A-p>", ":tabp<CR>")
Keymap("n", "<A-n>", ":tabn<CR>")
Keymap("n", "<A-c>", ":tabc<CR>")

-- Buffer navigation
Keymap("n", "<A-N>", ":bn<CR>")
Keymap("n", "<A-P>", ":bp<CR>")
Keymap("n", "<A-d>", ":bd<CR>")

-- Set splits navigation to just ALT + hjkl
Keymap("n", "<C-h>", "<C-w>h")
Keymap("n", "<C-j>", "<C-w>j")
Keymap("n", "<C-k>", "<C-w>k")
Keymap("n", "<C-l>", "<C-w>l")

-- Split size adjusting
Keymap("n", "<C-Left>", ":vertical resize +3<CR>")
Keymap("n", "<C-Right>", ":vertical resize -3<CR>")
Keymap("n", "<C-Up>", ":resize +3<CR>")
Keymap("n", "<C-Down>", ":resize -3<CR>")

-- Define some common shortcuts
Keymap("n", "<C-s>", ":w<CR>")
Keymap("i", "<C-s>", "<Esc>:w<CR>i")
Keymap("n", "<C-z>", ":undo<CR>")
Keymap("n", "<C-y>", ":redo<CR>")

-- Terminal
Keymap("n", "<C-t>", ":split term://zsh<CR>:resize -7<CR>i")
Keymap("n", "<C-A-t>", ":vnew term://zsh<CR>i")
Keymap("n", "<A-T>", ":tabnew term://zsh<CR>i")
Keymap("t", "<Esc>", "<C-\\><C-n>")

-- Use space for folding/unfolding sections
Keymap("n", "<space>", "za")
Keymap("v", "<space>", "zf")

-- Use shift to quickly move 10 lines up/down
Keymap("n", "K", "10k")
Keymap("n", "J", "10j")

-- Enable/Disable auto commenting
Keymap("n", "<leader>c", ":setlocal formatoptions-=cro<CR>")
Keymap("n", "<leader>C", ":setlocal formatoptions+=cro<CR>")

-- Don't leave visual mode after indenting
Keymap("v", "<", "<gv")
Keymap("v", ">", ">gv")

-- System clipboard copying
Keymap("v", "<C-c>", '"+y')

-- Alias replace all
Keymap("n", "<A-s>", ":%s//gI<Left><Left><Left>", {silent=false})

-- Stop search highlight with Esc
Keymap("n", "<esc>", ":noh<CR>")

-- Start spell-check
Keymap("n", "<leader>s", ":setlocal spell! spelllang=en_us<CR>")

-- Run shell check
Keymap("n", "<leader>p", ":!shellckeck %<CR>")

-- Compile opened file (using custom script)
Keymap("n", "<A-c>", ":w | !comp <c-r>%<CR>")

-- Close all opened buffers
Keymap("n", "<leader>Q", ":bufdo bdelete<CR>")

-- Don't set the incredibely annoying mappings that trigger dynamic SQL
-- completion with dbext and keeps on freezing vim whenever pressed with
-- a message saying that dbext plugin isn't installed
-- See :h ft-sql.txt
vim.g.omni_sql_no_default_maps = 1
