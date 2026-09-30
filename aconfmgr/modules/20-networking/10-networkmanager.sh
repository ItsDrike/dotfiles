# Install and enable NetworkManager
AddPackage networkmanager

CreateLink \
  /etc/systemd/system/multi-user.target.wants/NetworkManager.service \
  /usr/lib/systemd/system/NetworkManager.service

# Enable NetworkManager event hook service (dispatcher)
#
# This is a D-Bus activated service, which adds support for running scripts
# when NetworkManager reports network-related events.
#
# user scripts: /etc/NetworkManager/dispatcher.d
# default scripts: /usr/lib/NetworkManager/dispatcher.d/
CreateLink \
  /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service \
  /usr/lib/systemd/system/NetworkManager-dispatcher.service

# Don't manage saved connection profiles
#
# (They contain Wi-Fi credentials and host-specific network metadata)
IgnorePath '/etc/NetworkManager/system-connections'
