-- Keep Vesktop's messaging windows on workspace 4
hl.window_rule({
    name = "vesktop-workspace",
    match = { class = "vesktop" },
    workspace = "4",
})

-- Keep Firefox windows on workspace 2
hl.window_rule({
    name = "firefox-workspace",
    match = { class = "firefox" },
    workspace = "2",
})
