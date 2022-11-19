lvim.plugins = {
  -- LSP

  {
    -- Tree-like view for symbols in current file using LSP
    "simrat39/symbols-outline.nvim",
    config = function()
      require("symbols-outline").setup {
        width = 18,
        autofold_depth = 1,
      }
    end,
  },
  {
    -- Show function signature while typing
    "ray-x/lsp_signature.nvim",
    config = function()
      require("lsp_signature").on_attach()
    end,
    event = "BufRead",
  },

  -- User interface

  -- Autocompletion

  {
    -- Local AI completion helper
    "tzachar/cmp-tabnine",
    run = "./install.sh",
    requires = "hrsh7th/nvim-cmp",
  },

  -- {
  --   -- Github copilot for code completion
  --   "zbirenbaum/copilot.lua",
  --   event = { "VimEnter" },
  --   config = function()
  --     vim.defer_fn(function()
  --       require("copilot").setup()
  --     end, 100)
  --   end,
  -- },
  -- {
  --   -- Github compilot cmp source
  --   "zbirenbaum/copilot-cmp",
  --   after = { "copilot.lua", "nvim-cmp" }
  -- },


  -- Treesitter

  -- {
  --   -- Colorize matching parenthesis using treesitter
  --   "p00f/nvim-ts-rainbow",
  -- },

  {
    -- Treesitter information shown directly in neovim
    "nvim-treesitter/playground",
  },

  {
    -- Alwats show class/function name we're in
    "romgrk/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup {
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        throttle = true, -- Throttles plugin updates (may improve performance)
        max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
        patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
          -- For all filetypes
          -- Note that setting an entry here replaces all other patterns for this entry.
          -- By setting the 'default' entry below, you can control which nodes you want to
          -- appear in the context window.
          default = {
            "class",
            "function",
            "method",
            "while",
            "for",
            "if",
            "switch",
            "case",
          },
        },
      }
    end,
  },

  -- Other

  {
    -- Code time & habit tracking
    "wakatime/vim-wakatime"
  },

  {
    -- Make clipboard work on wayland (using wl-copy)
    "jasonccox/vim-wayland-clipboard"
  },

  {
    -- eww configuration language support
    "elkowar/yuck.vim"
  },

  {
    -- Goto preview (definition/implementation/references)
    "rmagatti/goto-preview",
    config = function()
      require('goto-preview').setup {}
    end
  },

}

-- Register copilot as cmp source
-- lvim.builtin.cmp.formatting.source_names["copilot"] = "(Copilot)"
-- table.insert(lvim.builtin.cmp.sources, 1, { name = "copilot" })

-- Register tabnine as cmp source
lvim.builtin.cmp.formatting.source_names["tabnine"] = "(Tabnine)"
table.insert(lvim.builtin.cmp.sources, { name = "tabnine" })
