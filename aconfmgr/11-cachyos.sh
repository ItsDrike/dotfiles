# Make CachyOS a hard requirement for applying the config
# Aconfmgr shouldn't be abused to configure cachyos on the system too.
# Doing so could easily run into issues and we don't really want that.
if ! pacman -Qq cachyos-keyring >/dev/null 2>&1; then
    printf 'CachyOS repositories must be configured before applying this configuration.\n' >&2
    exit 1
fi

# Include the CachyOS repos

AddPackage cachyos-keyring # CachyOS keyring
AddPackage cachyos-mirrorlist # CachyOS repository mirrorlist
AddPackage cachyos-v3-mirrorlist # CachyOS repository mirrorlist
AddPackage cachyos-v4-mirrorlist # CachyOS repository mirrorlist

# Include cachyos-rate-mirrors for automatic sorting of preferred mirrors
# (CachyOS version of reflector)
AddPackage cachyos-rate-mirrors # CachyOS - Rate mirrors service
CreateLink \
    /etc/systemd/system/timers.target.wants/cachyos-rate-mirrors.timer \
    /usr/lib/systemd/system/cachyos-rate-mirrors.timer
