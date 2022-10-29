local autocmd = vim.api.nvim_create_autocmd

autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.axaml" },
    command = "setfiletype xml"
})
