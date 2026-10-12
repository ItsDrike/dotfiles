# D-Bus-activated virtual filesystem backends used by desktop applications.
#
# Allows opening locations such as sftp:// in the file manager and GTK file
# dialogs.
AddPackage gvfs

# Additional network and device backends.
AddPackage gvfs-mtp # Android and other MTP devices
AddPackage gvfs-nfs # NFS shares
AddPackage gvfs-smb # SMB/CIFS shares
