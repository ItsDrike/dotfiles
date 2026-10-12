-- Highlight the active window when it is tiled or maximized by Hyprland but
-- reports fullscreen to its client. (We call this "fake fullscreen", as the
-- window thinks it's in fullscreen, which can allow certain behavior changes
-- in the application's rendering that are sometimes useful to us, without us
-- wanting the application to actually be full-screened on Hyprland though.)
--
-- Dynamic window rules restore the regular active and inactive border colors
-- automatically when the state no longer matches.

local fake_fullscreen_border = "rgba(FF6600FF)"

hl.window_rule({
    name = "client-fullscreen-tiled-border",
    match = {
        focus = true,
        fullscreen_state_internal = 0,
        fullscreen_state_client = 2,
    },
    border_color = fake_fullscreen_border,
})

hl.window_rule({
    name = "client-fullscreen-maximized-border",
    match = {
        focus = true,
        fullscreen_state_internal = 1,
        fullscreen_state_client = 2,
    },
    border_color = fake_fullscreen_border,
})
