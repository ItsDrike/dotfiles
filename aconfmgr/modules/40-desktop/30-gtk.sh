# GTK 3 is the mature GTK application toolkit runtime. It remains required by
# many desktop applications even as newer applications move to GTK 4.
AddPackage gtk3

# GTK 4 is the current GTK application toolkit runtime.
AddPackage gtk4

# DConf is the persistent settings database accessed through GSettings. Its
# D-Bus-activated service stores per-user desktop and application preferences.
AddPackage dconf

# Standard GSettings schemas for shared desktop preferences, including interface
# color scheme, fonts, icons, and input-device settings.
AddPackage gsettings-desktop-schemas
