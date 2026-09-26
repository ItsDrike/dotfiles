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
