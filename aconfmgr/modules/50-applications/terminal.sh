# Terminal emulator and its desktop-session integration.
AddPackage kitty

# Lets GTK/GLib launchers run Terminal=true desktop applications through the
# terminal selected in xdg-terminals.list.
#
# (As an example, this fixes using the nvim.desktop application entry from file
# roller to open a file from an archive with nvim running in kitty)
AddPackage xdg-terminal-exec

# Both UWSM's built-in terminal selector and xdg-terminal-exec read this list.
# Explicitly select Kitty instead of auto-discovering its URL-handler entry.
CopyFile /etc/xdg/xdg-terminals.list
