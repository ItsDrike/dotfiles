-- Permission rules are only read on Hyprland startup, not live-reloaded.

hl.config({
    ecosystem = {
        enforce_permissions = true,
    },
})

hl.permission({ binary = "/usr/(lib|lib64)/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/bin/grim", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/bin/wf-recorder", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/bin/hyprlock", type = "screencopy", mode = "allow" })

-- hl.permission({ binary = "/usr/(bin)/hyprpm", type = "plugin", mode = "allow" })
