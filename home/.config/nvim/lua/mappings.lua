local vim = require("vim")

-- Make these function definitions global as they could be reused
-- in plugin specific scripts or in other places.
function keymap(mode, shortcut, command, options)
    -- Assume silent, noremap unless specified otherwise
    local opts = {noremap=true, silent=true}
    if options then opts = vim.tbl_extend("force", opts, options) end
    -- Perform the actual remap
    vim.api.nvim_set_keymap(mode, shortcut, command, opts)
end

-- This is a bit silly, but I don't like passing the mode argument
-- to every keymap definition and this makes things a lot easier
-- and a bit more vimscript-like
function nmap(shortcut, command, options)
    keymap("n", shortcut, command, options)
end

function imap(shortcut, command, options)
    keymap("i", shortcut, command, options)
end

function vmap(shortcut, command, options)
    keymap("v", shortcut, command, options)
end

function tmap(shortcut, command, options)
    keymap("t", shortcut, command, options)
end

function xmap(shortcut, command, options)
    keymap("x", shortcut, command, options)
end

-- Unmap arrow keys in normal mode to remove bad habits
nmap("<Down>", "<nop>")
nmap("<Left>", "<nop>")
nmap("<Right>", "<nop>")
nmap("<Up>", "<nop>")

-- Tab navigation
nmap("<Tab>", "gt")
nmap("<S-Tab>", "gT")
nmap("<A-t>", ":tabnew<CR>")
nmap("<A-2>", ":tabmove +<CR>")
nmap("<A-1>", ":tabmove -<CR>")
nmap("<A-p>", ":tabp<CR>")
nmap("<A-n>", ":tabn<CR>")

-- Set splits navigation to just ALT + hjkl
nmap("<C-h>", "<C-w>h")
nmap("<C-j>", "<C-w>j")
nmap("<C-k>", "<C-w>k")
nmap("<C-l>", "<C-w>l")

-- Split size adjusting
nmap("<C-Right>", ":verical resize +3<CR>")
nmap("<C-Left>", ":vertical resize -3<CR>")
nmap("<C-Up>", ":resize +3<CR>")
nmap("<C-Down>", ":resize -3<CR>")

-- Define some common shortcuts
nmap("<C-s>", ":w<CR>")
imap("<C-s>", "<Esc>:w<CR>i")
nmap("<C-z>", ":undo<CR>")
nmap("<C-y>", ":redo<CR>")

-- Terminal
nmap("<C-t>", ":split term://zsh<CR>:resize -7<CR>i")
nmap("<C-A-t>", ":vnew term://zsh<CR>i")
nmap("<A-T>", ":tabnew term://zsh<CR>i")
tmap("<Esc>", "<C-\\><C-n>")

-- Use space for folding/unfolding sections
nmap("<space>", "za")
vmap("<space>", "zf")

-- Use shift to quickly move 10 lines up/down
nmap("K", "10k")
nmap("J", "10j")

-- Enable/Disable auto commenting
nmap("<leader>c", ":setlocal formatoptions-=cro<CR>")
nmap("<leader>C", ":setlocal formatoptions+=cro<CR>")

-- Don't leave visual mode after indenting
vmap("<", "<gv")
vmap(">", ">gv")

-- System clipboard copying
vmap("<C-c>", '"+y')

-- Alias replace all
nmap("<A-s>", ":%s//gI<Left><Left><Left>", {silent=false})

-- Stop search highlight with Esc
nmap("<esc>", ":noh<CR>")

-- Start spell-check
nmap("<leader>s", ":setlocal spell! spelllang=en_us<CR>")

-- Run shell check
nmap("<leader>p", ":!shellckeck %<CR>")

-- Compile opened file (using custom script)
nmap("<A-c>", ":w | !comp <c-r>%<CR>")

-- Close all opened buffers
nmap("<leader>Q", ":bufdo bdelete<CR>")

-- Don't set the incredibely annoying mappings that trigger dynamic SQL
-- completion with dbext and keeps on freezing vim whenever pressed with
-- a message saying that dbext plugin isn't installed
-- See :h ft-sql.txt
vim.g.omni_sql_no_default_maps = 1
