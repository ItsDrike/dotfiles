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
})
