local vim = require("vim")
local g = vim.g
local fn = vim.fn
local cmd = vim.cmd

cmd[[
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
]]

-- Implement manual NERDTreeToggle, but use NERDTreeFind for openning.
-- This makes NERDTree open with the current file pre-selected
Keymap("n", "<C-n>", "g:NERDTree.IsOpen() ? ':NERDTreeClose<CR>' : @% == '' ? ':NERDTree<CR>' : ':NERDTreeFind<CR>'", {expr=true})

g.NERDTreeShowHidden = 1
g.NERDTreeMinimalUI = 1
g.NERDTreeShowLineNumbers = 0
g.NERDTreeWinSize = 25

g.NERDTreeDirArrowExpandable = '►'
g.NERDTreeDirArrowCollapsible = '▼'

-- Disable devicons for nerdtree in TTY
if not os.getenv("DISPLAY") then
    g.webdevicons_enable_nerdtree = 0
else
    g.DevIconsEnableFoldersOpenClose = 1
end

-- If a directory is specified, start NERDTree
cmd[[
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] |
    \ endif
]]

-- Exit Vim if NERDTree is the only window left.
cmd[[
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif
]]

-- If another buffer tries to replace NerdTree, put it in another window, and bring back NerdTree.
cmd[[
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif
]]

-- Use $NERDTREE_BOOKMARKS environment variable for the location of .NERDTreeBookmarks file
local bookmark_loc = os.getenv("NERDTREE_BOOKMARKS")
if bookmark_loc then
    -- Check if file exists (lua doesn't have a built-in function for this)
    local file_exists = os.rename(bookmark_loc, bookmark_loc) and true or false

    if not file_exists then
        -- While this is possible with os.execute in lua, we would need to do some hacky
        -- things to capture output from os.execute and it's simpler to just use vimscript
        local dir = fn.system("dirname $NERDTREE_BOOKMARKS")
        fn.system({"mkdir", "-p", dir})
        fn.system("touch $NERDTREE_BOOKMARKS")
    end
    g.NERDTreeBookmarksFile = bookmark_loc
end
