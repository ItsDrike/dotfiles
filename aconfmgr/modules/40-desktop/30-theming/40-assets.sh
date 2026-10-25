# Papirus supplies the base icon set. The Catppuccin companion replaces its
# folder colors with the selected Mocha/blue variant.
AddPackage papirus-icon-theme
AddPackage --foreign papirus-folders-catppuccin-git

# Use XCursor Pro Light as the cursor theme. We also install a Hyprcursor
# package for the same theme that lets Hyprland and some native Wayland clients
# (either ones which are expliciitly Hyprcursor aware, or, more likely, ones
# using the cursor shave protocol that lets the compositor give the app a
# specific requested cursor) use dynamically scalable SVG cursors that are much
# better at working with various scaled resolutions and requested cursor sizes.
AddPackage --foreign xcursor-pro-cursor-theme
AddPackage --foreign xcursor-pro-hyprcursor
