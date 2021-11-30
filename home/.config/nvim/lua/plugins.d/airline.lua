local vim = require("vim")
local g = vim.g
local cmd = vim.cmd

cmd[[
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
]]

-- Airline specific theming settings
g.airline_theme = 'codedark'            -- Use codedark theme from vim-airline-themes
g.airline_right_sep = ""                -- Don't use special separators (<)
g.airline_left_sep = ""                 -- Don't use special separators (>)

-- Tabline setup
-- TODO: Figure out how to set # separated variables in lua (open for PRs)
cmd[[let g:airline#extensions#tabline#enabled = 1]]     -- Enable tabline (top line)
cmd[[let g:airline#tabline#formatter = 'unique_tail']]  -- Tabline filename formatter

-- Special symbols
g.webdevicons_enable_airline_statusline = 0 -- Use special icons from vim-devicons (requires nerdfonts)
g.airline_powerline_fonts = 1               -- Use special symbols from poweline fonts (line no, col no)
if not os.getenv("DISPLAY") then            -- Use ASCII-only if we're in TTY
    g.airline_symbols_ascii = 1
end

-- Disable airline in nerdtree buffer
-- TODO; For some reason, this fails even though it works in regular vimscript
--[[
cmd[[
augroup filetype_nerdtree
    au!
    au FileType nerdtree call s:disable_airline_on_nerdtree()
    au WinEnter,BufWinEnter,TabEnter * call s:disable_airline_on_nerdtree()
augroup END

fu s:disable_airline_on_nerdtree() abort
    let nerdtree_winnr = index(map(range(1, winnr('$')), {_,v -> getbufvar(winbufnr(v), '&ft')}), 'nerdtree') + 1
    call timer_start(0, {-> nerdtree_winnr && setwinvar(nerdtree_winnr, '&stl', '%#Normal#')})
endfu
]]
--]]
