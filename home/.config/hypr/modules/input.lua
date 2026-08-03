-- Monitor layout. The final empty-output rule mirrors unspecified external
-- monitors to the laptop panel, matching your current fallback rule.
hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "0x0", scale = 1 })
hl.monitor({ output = "desc:Microstep MSI MAG 256F BC1H174600235", mode = "1920x1080@120", position = "1920x0", scale = 1 })
hl.monitor({ output = "desc:AOC 2260WG5 KBEH81A000795", mode = "1920x1080@60", position = "1920x0", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })

hl.config({
    input = {
        kb_layout = "us, sk",
        kb_variant = ",qwerty",
        kb_options = "grp:alt_shift_toggle",
        numlock_by_default = true,
        follow_mouse = 1,

        touchpad = {
            middle_button_emulation = true,
            natural_scroll = false,
        },
    },
})
