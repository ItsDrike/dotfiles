###############################################################################
# Bluetooth stack and management
###############################################################################

# BlueZ provides bluetoothd; bluez-utils provides bluetoothctl and diagnostic
# tools. Blueman provides graphical device management and a pairing agent.
AddPackage bluez
AddPackage bluez-utils
AddPackage blueman

# Enable the daemon and its D-Bus service alias, as declared by its unit.
CreateLink /etc/systemd/system/bluetooth.target.wants/bluetooth.service /usr/lib/systemd/system/bluetooth.service
CreateLink /etc/systemd/system/dbus-org.bluez.service /usr/lib/systemd/system/bluetooth.service

# Pairings, trust and adapter state are machine-local, potentially sensitive
# runtime data; they are not declarative system configuration.
IgnorePath /var/lib/bluetooth
