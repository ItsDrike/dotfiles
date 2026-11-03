# Hyprland is the Wayland compositor for graphical sessions.
AddPackage hyprland

# Lightweight Hyprland-native wallpaper daemon. Its user configuration and
# UWSM-managed service are deployed through Chezmoi.
AddPackage hyprpaper

# Hyprland implementation of the XDG screenshot, screencast, global-shortcut,
# and input-capture portals. Its packaged portal configuration selects this
# backend with the generic GTK fallback.
AddPackage xdg-desktop-portal-hyprland
