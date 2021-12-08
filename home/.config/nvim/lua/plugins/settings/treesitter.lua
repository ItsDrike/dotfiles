local vim = require("vim")
local g = vim.g

-- Enable treesitter highlight for all languages
require'nvim-treesitter.configs'.setup {
    -- Always automatically install parsers for these languages
    ensure_installed = {
        "bash", "python", "lua", "rust", "go", "haskell",
        "c", "cpp", "cmake", "c_sharp", "java", "dockerfile",
        "json", "toml", "yaml", "regex", "vim", "html", "css",
        "typescript", "javascript",
    },
    highlight = {
        enable = true,
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
  },
}

-- Use git instead of curl for downloading parsers
require("nvim-treesitter.install").prefer_git = true

-- Use treesitter for syntax-aware folding
g.foldmethod = "expr"
g.foldexpr = "nvim_treesitter#foldexpr()"
