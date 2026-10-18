# Desktop notification client library (contains the notify-send command).
#
# This provides support/interactions with D-Bus notifications service.
AddPackage libnotify

# Notification daemon and control center. Its user service starts with the
# graphical session and is assigned to UWSM's graphical-session slice below.
AddPackage swaync
CreateLink \
  /etc/systemd/user/graphical-session.target.wants/swaync.service \
  /usr/lib/systemd/user/swaync.service
CopyFile /etc/systemd/user/swaync.service.d/10-uwsm.conf
