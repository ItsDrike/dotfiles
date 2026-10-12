-- Signal UWSM once Hyprland has loaded its configuration. Graphical-session
-- lifecycle and application autostart otherwise remain UWSM/systemd concerns
hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm finalize")
end)
