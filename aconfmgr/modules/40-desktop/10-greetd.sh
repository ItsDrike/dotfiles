# Console display manager and greeter.
AddPackage greetd
AddPackage greetd-tuigreet

# greetd configuration
CopyFile /etc/greetd/config.toml

# Make greetd the active display manager.
CreateLink \
  /etc/systemd/system/display-manager.service \
  /usr/lib/systemd/system/greetd.service

# Custom TTY shell session entry
CopyFile /usr/local/bin/user-login-shell 755
CopyFile /usr/share/wayland-sessions/tty-shell.desktop
