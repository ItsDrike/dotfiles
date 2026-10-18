# FUSE: Filesystem in Userspace
#
# It gives userspace programs the ability to handle / provide file-system
# interactions. The Linux kernel already contains fuse support, this installs
# the library and helper tooling that programs use to interact with that kernel
# support.
#
# Essentially, a kernel handles FUSE mounts by forwarding any fs interaction
# (reading/writing a file, showing the list of files, ...) to the userspace
# program that's managing it, making those userspace programs act like drivers,
# processing the interactions over some kernel ABI, without actually having to
# be running in the kernel as real included drivers.
AddPackage fuse3 # Modern FUSE implementation, used by GVFS and most modern apps
AddPackage fuse2 # Older FUSE lib version, installed for compatibility reasons

# GVFS: GNOME Virtual File System
#
# GVFS is a service providing file-access. It lets applications work with
# locations that are not normal local folders, such as SFTP servers, SMB
# shares, Android phones, the desktop trash, ... An application usually
# accesses GVFS through GIO (part of GLib), which accepts both normal paths and
# URIs, such as `sftp://server.example/home/me`. GVFS itself runs as a
# user-session systemd service, GIO then communicates with this service over
# D-Bus.
#
# GVFS has backends for each type of location, e.g. the SFTP backend handles
# connecting to an SSH server and processing file-system interactions through
# that connection. The GVFS daemon selects the backend based on the URI scheme.
#
# Applications that use GVFS can use these locations directly and do not need
# FUSE. However, GVFS will also expose the active remote locations as normal
# paths under /run/user/$UID/gvfs/ through FUSE, so that other non-GVFS aware
# apps can interact with these locations too.
AddPackage gvfs

# Additional network and device backends.
AddPackage gvfs-mtp # Android and other MTP devices
AddPackage gvfs-nfs # NFS shares
AddPackage gvfs-smb # SMB/CIFS shares
