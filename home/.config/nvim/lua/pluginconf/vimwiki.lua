local vim = require("vim")
local cmd = vim.cmd
local g = vim.g

local wiki_conf = {}
wiki_conf["path"] = "~/Personal/vimwiki"
wiki_conf["path_html"] = "~/Personal/vimwiki-html"
wiki_conf["html_template"] = "~/Personal/vimwiki-html/template.tpl"
wiki_conf["syntax"] = "markdown"
wiki_conf["ext"] = ".md"
g.vimwiki_list = {wiki_conf}

