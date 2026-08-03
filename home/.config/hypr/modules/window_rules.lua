-- Assigned workspaces.
hl.window_rule({ match = { class = "firefox" }, workspace = "2" })
hl.window_rule({ match = { class = "discord" }, workspace = "4" })
hl.window_rule({ match = { class = "vesktop" }, workspace = "4" })
hl.window_rule({ match = { class = "WebCord" }, workspace = "4" })
hl.window_rule({ match = { class = "Spotify" }, workspace = "5" })
hl.window_rule({ match = { class = "Stremio" }, workspace = "6" })
hl.window_rule({ match = { class = "com.stremio.stremio" }, workspace = "6" })

-- Correct size / auto tile / auto float.
hl.window_rule({ match = { class = "qalculate-gtk" }, float = true })
hl.window_rule({ match = { class = "qalculate-gtk" }, center = true })
hl.window_rule({ match = { class = "qalculate-gtk" }, size = { 800, 550 } })

hl.window_rule({ match = { class = "hyprland-share-picker" }, float = true })
hl.window_rule({ match = { class = "hyprland-share-picker" }, center = true })
hl.window_rule({ match = { class = "hyprland-share-picker" }, animation = "slide" })

hl.window_rule({ match = { class = "pcmanfm-qt", title = "Mount" }, float = true })
hl.window_rule({ match = { class = "pcmanfm-qt", title = "Preferences" }, float = true })
hl.window_rule({ match = { class = "pcmanfm-qt", title = "Move files" }, float = true })
hl.window_rule({ match = { class = "pcmanfm-qt", title = "Search Files" }, float = true })
hl.window_rule({ match = { class = "pcmanfm-qt", title = "Copy Files" }, float = true })
hl.window_rule({ match = { class = "pcmanfm-qt", title = "Confirm to replace files" }, float = true })
hl.window_rule({ match = { class = "pcmanfm-qt", title = "Choose an Application" }, float = true })

-- Float all windows that don't have a title nor a class.
hl.window_rule({ match = { class = "^$", title = "^$" }, float = true })

hl.window_rule({ match = { class = "file-roller" }, float = true })
hl.window_rule({ match = { class = "opensnitch_ui" }, float = true })
hl.window_rule({ match = { class = "Brave-browser", title = "(_crx_.+)" }, float = true })
hl.window_rule({ match = { class = "qimgv", title = "Add shortcut" }, float = true })

-- Ignore maximize requests from apps.
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Fix some dragging issues with XWayland.
hl.window_rule({
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})
