-- Keep Vesktop's messaging windows on workspace 4
hl.window_rule({
    name = "vesktop-workspace",
    match = { class = "vesktop" },
    workspace = "4",
})
