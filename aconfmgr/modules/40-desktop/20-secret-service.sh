# GNOME Keyring provides the freedesktop.org Secret Service API used by desktop
# applications to store credentials, tokens, and other per-user secrets.
AddPackage gnome-keyring

# Enable the packaged per-user socket. The daemon will start on demand when a
# client requests Secret Service functionality.
CreateLink \
  /etc/systemd/user/sockets.target.wants/gnome-keyring-daemon.socket \
  /usr/lib/systemd/user/gnome-keyring-daemon.socket

# Graphical utility for inspecting and managing Secret Service items as well as
# OpenPGP and SSH keys.
AddPackage seahorse
