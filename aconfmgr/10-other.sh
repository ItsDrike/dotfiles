# Add XDG User Dirs
#
# (This is a standard freedesktop.org convention for telling applications where
# a user keeps common human-facing folders, such as ~/Downloads and ~/Music
# instead of having applications assume their paths.)
#
# We also enable the xdg-user-dirs.service, which automatically updates/creates
# the specified directories.
AddPackage xdg-user-dirs
CreateLink \
  /etc/systemd/user/graphical-session-pre.target.wants/xdg-user-dirs.service \
  /usr/lib/systemd/user/xdg-user-dirs.service

# Enable socket activation for systemd-userdbd
#
# systemd-userdbd provides a local user/group database service for components
# using systemd's UserDB/Varlink APIs (such as dynamic users, systemd-homed,
# userdbctl and NSS integration).
CreateLink \
  /etc/systemd/system/sockets.target.wants/systemd-userdbd.socket \
  /usr/lib/systemd/system/systemd-userdbd.socket

# Enable p11-kit-server socket activation
#
# Provides a local, on-demand PKCS#11 service for user applications.
#
# PKCS#11 is the standard interface for cryptographic tokens such as smart
# carts, USB security keys (e.g. a Yubikey device), crypto hardware (TPM-backed
# keys / HSMs), allowing applications to discover and use their certificates
# and keys.
CreateLink \
  /etc/systemd/user/sockets.target.wants/p11-kit-server.socket \
  /usr/lib/systemd/user/p11-kit-server.socket
