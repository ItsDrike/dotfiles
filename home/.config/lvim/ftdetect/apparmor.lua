local autocmd = vim.api.nvim_create_autocmd

autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "/etc/apparmor.d/*" },
    command = "setfiletype apparmor"
})

autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "/usr/share/apparmor/extra-profiles/*" },
    command = "setfiletype apparmor"
})
