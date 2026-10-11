# Terminal emulator and its desktop-session integration.
AddPackage kitty

# UWSM uses xdg-terminal-exec entries for `uwsm-terminal`. Explicitly select
# Kitty's terminal entry instead of auto-discovering the kitty-open URL handler.
CopyFile /etc/xdg/xdg-terminals.list
