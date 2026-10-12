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

# Future: watch the draft Terminal Intent and Application Intents specs:
# <https://specifications.freedesktop.org/terminal-intent/latest/>
# <https://specifications.freedesktop.org/intent-apps/latest/>
#
# It would standardize default-terminal selection through the draft Application
# Intents specification and `intentapps.list`, then use the
# org.freedesktop.Terminal1 D-Bus API to launch an empty shell or a command with
# its argument vector, working directory, environment, activation metadata, and
# optional keep-open behavior. It is more structured and sandbox-friendly than
# directly executing a terminal emulator.
#
# We do not configure it yet  as both specifications are draft 0.1, and Kitty
# does not advertise or implement org.freedesktop.Terminal1. Keep the practical
# xdg-terminal-exec/UWSM integration above until the terminal and desktop stack
# support Terminal Intent.
