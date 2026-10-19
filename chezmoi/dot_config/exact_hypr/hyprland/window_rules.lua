-- Keep Vesktop's messaging windows on workspace 4
hl.window_rule({
    name = "vesktop-workspace",
    match = { class = "vesktop" },
    workspace = "4",
})

-- Qalculate doesn't look correct at any other size than it's desired 800x550
-- Make it float and centered, with this size when it's opened
hl.window_rule({
    name = "qalculate-float",
    match = { class = "qalculate-gtk" },
    float = true,
    center = true,
    size = { 800, 550 },
})
