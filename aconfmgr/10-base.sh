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
AddPackage man-db # A utility for reading man pages
AddPackage man-pages # Linux man pages
AddPackage networkmanager # Network connection manager and user applications
AddPackage openssh # SSH protocol implementation for remote login, command execution and file transfer
AddPackage ripgrep # A search tool that combines the usability of ag with the raw speed of grep
AddPackage fd # Simple, fast and user-friendly alternative to find
AddPackage go-yq # Portable command-line YAML processor
AddPackage jq # Command-line JSON processor
AddPackage sbctl # Secure Boot key manager
AddPackage efitools # Tools for manipulating UEFI secure boot platforms
AddPackage usbutils # A collection of USB tools to query connected USB devices
AddPackage lsof # Lists open files for running Unix processes
AddPackage net-tools # Configuration tools for Linux networking
AddPackage bind # A complete, highly portable implementation of the DNS protocol
AddPackage zip # Compressor/archiver for creating and modifying zipfiles
AddPackage 7zip # File archiver for extremely high compression
AddPackage unrar # The RAR uncompression program
AddPackage wget # Network utility to retrieve files from the web
AddPackage curl # command line tool and library for transferring data with URLs
AddPackage rsync # A fast and versatile file copying tool for remote and local files
AddPackage ntp # Network Time Protocol reference implementation
AddPackage fwupd # Simple daemon to allow session software to update firmware
AddPackage pacman-contrib # Contributed scripts and tools for pacman systems
AddPackage paru # Feature packed AUR helper

## Other packages

AddPackage arch-audit # A utility like pkg-audit based on Arch Security Team data
AddPackage btop # A monitor of system resources, bpytop ported to C++
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

# Disable the legacy PC speaker bell in the initrd and the running system.
# (I would rather physically remove the motherboard speaker than have my
# system beep at me, luckily, we can disable it from software)
CopyFile /etc/modprobe.d/nobeep.conf

## Systemd units

# NetworkManager
CreateLink \
  /etc/systemd/system/multi-user.target.wants/NetworkManager.service \
  /usr/lib/systemd/system/NetworkManager.service
CreateLink \
  /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service \
  /usr/lib/systemd/system/NetworkManager-dispatcher.service

# Automated pacman cache cleanup (from pacman-contrib)
CreateLink \
  /etc/systemd/system/timers.target.wants/paccache.timer \
  /usr/lib/systemd/system/paccache.timer

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
