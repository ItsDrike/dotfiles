hl.config({
    general = {
        layout = "dwindle",
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,

        -- Window border colors.
        col = {
            active_border = "rgba(ffa500ff)",
            inactive_border = "rgba(666666aa)",
            nogroup_border_active = "rgba(ff00ffff)",
            nogroup_border = "rgba(ff00ffaa)",
        },
    },

    dwindle = {
        preserve_split = true,
        special_scale_factor = 0.95,
        split_width_multiplier = 1.1,
    },

    group = {
        auto_group = false,
        col = {
            border_active = "rgba(00a500ff)",
            border_inactive = "rgba(5aa500ff)",
            border_locked_active = "rgba(a0a500ff)",
            border_locked_inactive = "rgba(a0a500aa)",
        },

        groupbar = {
            render_titles = false,
            font_size = 11,
            text_color = "rgba(FFFFFFFF)",
            gradients = false,
            col = {
                active = "rgba(FFA500FF)",
                inactive = "rgba(00A500AA)",
                locked_active = "rgba(FF8000FF)",
                locked_inactive = "rgba(A0A500AA)",
            },
            scrolling = false,
        },
    },

    decoration = {
        rounding = 8,
        rounding_power = 2,
        shadow = {
            -- Disabled for battery and because the visual difference is minor.
            enabled = false,
            range = 4,
            render_power = 3,
            color = "rgba(0f0f0fe6)",
            color_inactive = "rgba(0f0f0f99)",
        },
        blur = {
            enabled = true,
            size = 6,
            passes = 1,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = -1,
    },
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "default", style = "slidefadevert" })
