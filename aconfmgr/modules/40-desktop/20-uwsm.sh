# Universal Wayland Session Manager
#
# A wrapper for Wayland compositors that manages them and their applications as
# systemd user units. It provides XDG autostart support, orderly shutdown, and
# separate systemd slices for session, background, and regular applications.
#
# - <https://github.com/Vladimir-csp/uwsm>
# - <https://wiki.archlinux.org/title/Universal_Wayland_Session_Manager>
AddPackage uwsm

# UWSM uses libnewt's whiptail interface as an optional dependency, to select a
# compositor with `uwsm select` / `uwsm start select` or `uwsm start default`
# when uwsm has no saved default-id yet, such as on first login.
AddPackage libnewt

# Keep the generic Polkit agent in UWSM's graphical-session slice for orderly
# shutdown and session-scoped resource accounting.
CopyFile /etc/systemd/user/polkit-gnome-agent.service.d/10-uwsm.conf
