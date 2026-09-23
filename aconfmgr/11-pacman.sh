# Pacman configuration and repository policy.
# (This assumes CachyOS)

###############################################################################
## Base
###############################################################################

# CachyOS repository support must be installed during bootstrap.
# That should have configured its repositories and keyring.
# This just tracks those packages in aconfmgr:
AddPackage cachyos-keyring
AddPackage cachyos-mirrorlist
AddPackage cachyos-v3-mirrorlist
AddPackage cachyos-v4-mirrorlist

# I like paru as my AUR helper
# (CachyOS has it in their repos directly, so no need for --foreign)
AddPackage paru

# Main pacman configuration
CopyFile /etc/pacman.conf

###############################################################################
## Extra
###############################################################################

# Contains various useful pacman utilities and systemd timers
AddPackage pacman-contrib

# Runs `paccache` weekly.
# (Cleans up old package archives from /var/cache/pacman/pkg)
CreateLink \
  /etc/systemd/system/timers.target.wants/paccache.timer \
  /usr/lib/systemd/system/paccache.timer

# Run `pacman -Fy` weekly, refreshing the local pacman file database
CreateLink \
  /etc/systemd/system/timers.target.wants/pacman-filesdb-refresh.timer \
  /usr/lib/systemd/system/pacman-filesdb-refresh.timer

# CachyOS mirror ranking service
# (Similar to reflector, but works for CachyOS mirrors too)
AddPackage cachyos-rate-mirrors

# Enable cachyos-rate-mirrors. Runs ~3 times per month.
CreateLink \
  /etc/systemd/system/timers.target.wants/cachyos-rate-mirrors.timer \
  /usr/lib/systemd/system/cachyos-rate-mirrors.timer
