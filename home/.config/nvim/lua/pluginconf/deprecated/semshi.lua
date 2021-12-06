local vim = require("vim")
local cmd = vim.cmd
local fn = vim.fn

-- Unused because the extension significantly slows down the opening time for vim.
-- Also, while the semantic highlighting in it is neat, for me, it isn't worth in.
--
-- The extension default colorscheme makes the code look like unicorn vommit.
-- I'd prefer a simpler extension that only really distinguishes between classes,
-- functions and perhaps unused variables. I don't need to see a different color
-- when I access something as an attribute, but it would be neat to see what that
-- attribute actually holds, is it a class or a fucntion. But from my searching,
-- I wasn't able to find anything like this. This is open to pull requests.
cmd[[Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins' }]]

if (fn.has("python3")) then
    fn.system({"pip", "install", "nvim", "--upgrade"})
end

cmd[[
function MyCustomHighlights()
    hi semshiParameter  ctermfg=117 guifg=#93CCED
    hi semshiParameterUnused ctermfg=117 guifg=#5e8193 cterm=underline gui=underline
    hi semshiBuiltin         ctermfg=29 guifg=#48bda5
    hi semshiAttribute       ctermfg=254  guifg=#d1d1d1
    hi semshiImported        ctermfg=214 guifg=#f8c466 cterm=bold gui=bold
    hi semshiLocal           ctermfg=209 guifg=#ff875f
endfunction

autocmd FileType python call MyCustomHighlights()
]]
