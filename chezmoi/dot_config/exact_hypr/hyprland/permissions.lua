-- Permission rules are read only when Hyprland starts, not live-reloaded
hl.config({
    ecosystem = {
        enforce_permissions = true,
    },
})

-- The Hyprland XDG desktop portal is the primary method through which apps
-- should request screen sharing. This portal itself should be considered as
-- trusted and skip Hyprland's screencopy permission prompt (it contains it's
-- own per-request prompt anyway)
hl.permission({
    binary = "/usr/lib/xdg-desktop-portal-hyprland",
    type = "screencopy",
    mode = "allow",
})

-- Other apps attempting to use direct screencopy without going through the
-- portal will need explicit user confirmation from a dialog that will be shown
-- by Hyprland

-- Grim is used for taking screenshots
hl.permission({
    binary = "/usr/bin/grim",
    type = "screencopy",
    mode = "allow",
})
