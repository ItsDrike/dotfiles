hl.config({
    misc = {
        -- Do not let an application interrupt current work by requesting focus
        focus_on_activate = false,

        -- Wake displays from ordinary user activity
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,

        -- Disable primary-selection clipboard paste on middle-click
        middle_click_paste = false,
    },
    render = {
        -- Disable automatic HDR mode-setting for apps that support HDR
        --
        -- By default, when on an HDR capable display, Hyprland will offer any
        -- full-screen apps HDR. If the app accepts it, Hyprland will switch
        -- the monitor's output into HDR.
        --
        -- However, this switching means that Hyprland has to perform
        -- mode-setting which usually chagnes the color management mode for the
        -- panel from srgb / SDR to HDR mode. This switch often causes a full
        -- black screen transition for that monitor though.
        --
        -- Many HDR capable apps, like chromium, will therefore transition
        -- every time when they go in or out of full-screen. This transition
        -- can trigger black screen reloads which, on some HDR capable external
        -- monitors, can cause up to 5 seconds. Even on internal (built in
        -- laptop) displays, it can often cause a black screen, usually for
        -- shorter, but it's quite annoying regardless.
        --
        -- This can sometimes be mitigated by running the display in HDR color
        -- management mode all the time, or (though only in some cases) by at
        -- least running the display in wide color management mode (with 10-bit
        -- color), which, for some panels, avoids the full black screen
        -- transition.
        --
        -- Regardless, for the monitors I've tested this with, HDR seems to
        -- just be more trouble than it's worth, it's often too dim and even
        -- with just the wide / 10-bit color management mode on my monitors, so
        -- that HDR switch doesn't cause a black-screen, the 10-bit colors seem
        -- less vibrant (that may technically be closer to how they "should"
        -- look, but I don't really like it.)
        --
        -- For this reason, I disable this automatic HDR advertisement from
        -- Hyprland to full-screened apps and just use the monitor's 
        cm_auto_hdr = 0,
    },
})
