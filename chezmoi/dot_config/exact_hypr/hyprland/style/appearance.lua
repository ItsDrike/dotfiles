hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,

        col = {
            active_border = "rgba(ffa500ff)",
            inactive_border = "rgba(666666aa)",
        },
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
            -- Disabled for battery and because the visual difference is minor
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

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})
