# XDG Desktop Portals provide D-Bus APIs through which sandboxed applications
# can request desktop integration such as file selection, settings, and
# notifications. Backends are activated on demand over D-Bus.
AddPackage xdg-desktop-portal

# Generic GTK portal implementation for file selection and other standard
# desktop-integration requests. Compositor-specific backends provide screen
# capture and input portals separately.
AddPackage xdg-desktop-portal-gtk
