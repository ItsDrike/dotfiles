-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = {}
lvim.builtin.treesitter.highlight.enabled = true
-- lvim.builtin.treesitter.rainbow.enable = true

-- local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
-- parser_config.apparmor = {
--   install_info = {
--     url = "~/Personal/Programming/GitHub/Other/tree-sitter-apparmor", -- local path or git repo
--     files = {"src/parser.c"},
--     -- optional entries:
--     branch = "main", -- default branch in case of git repo if different from master
--     generate_requires_npm = false, -- if stand-alone parser without npm dependencies
--     requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
--   },
--   filetype = "apparmor", -- if filetype does not match the parser name
-- }
--
-- local ft_to_parser = require"nvim-treesitter.parsers".filetype_to_parsername
-- ft_to_parser.apparmor = "apparmor"

-- Temporary treesitter
lvim.keys.normal_mode["gu"] = ":TSUpdate apparmor<CR>"
lvim.keys.normal_mode["gU"] = ":TSToggle apparmor<CR>"
lvim.keys.normal_mode["gt"] = ":TSPlaygroundToggle<CR>"
lvim.keys.normal_mode["gh"] = ":TSNodeUnderCursor<CR>"
lvim.keys.normal_mode["gH"] = ":TSHighlightCapturesUnderCursor<CR>"
