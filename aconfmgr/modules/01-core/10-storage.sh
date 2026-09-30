AddPackage btrfs-progs # Btrfs filesystem utilities
AddPackage cryptsetup # Userspace setup tool for transparent encryption of block devices using dm-crypt

# Enable weekly SSD TRIMming
CreateLink \
  /etc/systemd/system/timers.target.wants/fstrim.timer \
  /usr/lib/systemd/system/fstrim.timer

CreateLink \
  /etc/systemd/system/multi-user.target.wants/remote-fs.target \
  /usr/lib/systemd/system/remote-fs.target
