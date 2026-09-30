## Core / System critical packages

AddPackage --foreign aconfmgr-git # A configuration manager for Arch Linux

AddPackage base # Minimal package set to define a basic Arch Linux installation
AddPackage base-devel # Basic tools to build Arch Linux packages
AddPackage arch-install-scripts # Provides arch-chroot and other Arch installation helpers
AddPackage sbctl # Secure Boot key manager
AddPackage efitools # Tools for manipulating UEFI secure boot platforms

## Configs

CopyFile /etc/environment.d/10-editor.conf

## Systemd units

# Other
CreateLink \
  /etc/systemd/system/sockets.target.wants/systemd-userdbd.socket \
  /usr/lib/systemd/system/systemd-userdbd.socket
CreateLink \
  /etc/systemd/user/sockets.target.wants/p11-kit-server.socket \
  /usr/lib/systemd/user/p11-kit-server.socket

## Other

SetFileProperty / mode 555
