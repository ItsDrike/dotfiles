## Core / System critical packages

AddPackage --foreign aconfmgr-git # A configuration manager for Arch Linux

AddPackage base # Minimal package set to define a basic Arch Linux installation
AddPackage base-devel # Basic tools to build Arch Linux packages
AddPackage btrfs-progs # Btrfs filesystem utilities
AddPackage cryptsetup # Userspace setup tool for transparent encryption of block devices using dm-crypt
AddPackage git # the fast distributed version control system
AddPackage sudo # Give certain users the ability to run some commands as root
AddPackage neovim # Fork of Vim aiming to improve user experience, plugins, and GUIs
AddPackage less # A terminal based program for viewing text files
AddPackage networkmanager # Network connection manager and user applications
AddPackage openssh # SSH protocol implementation for remote login, command execution and file transfer
AddPackage ripgrep # A search tool that combines the usability of ag with the raw speed of grep
AddPackage sbctl # Secure Boot key manager
AddPackage efitools # Tools for manipulating UEFI secure boot platforms
AddPackage usbutils # A collection of USB tools to query connected USB devices
AddPackage paru # Feature packed AUR helper

## Other packages

AddPackage macchina # A  system information fetcher, with an (unhealthy) emphasis on performance.
AddPackage rustup # The Rust toolchain installer

## Configs

# Pacman config
CopyFile /etc/pacman.conf

# Sudo config
CopyFile /etc/sudoers.d/10-wheel 440
CopyFile /etc/sudoers.d/99-insults 440

# Virtual console configuration (TTY)
CopyFile /etc/vconsole.conf

## Systemd units

# NetworkManager
CreateLink \
  /etc/systemd/system/multi-user.target.wants/NetworkManager.service \
  /usr/lib/systemd/system/NetworkManager.service
CreateLink \
  /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service \
  /usr/lib/systemd/system/NetworkManager-dispatcher.service

# Other
CreateLink \
  /etc/systemd/system/autovt@.service \
  /usr/lib/systemd/system/getty@.service
CreateLink \
  /etc/systemd/system/getty.target.wants/getty@tty1.service \
  /usr/lib/systemd/system/getty@.service
CreateLink \
  /etc/systemd/system/multi-user.target.wants/remote-fs.target \
  /usr/lib/systemd/system/remote-fs.target
CreateLink \
  /etc/systemd/system/sockets.target.wants/systemd-userdbd.socket \
  /usr/lib/systemd/system/systemd-userdbd.socket
CreateLink \
  /etc/systemd/user/sockets.target.wants/p11-kit-server.socket \
  /usr/lib/systemd/user/p11-kit-server.socket

## Other

SetFileProperty / mode 555
