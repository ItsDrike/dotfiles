# Unrelated subvolumes and paths
IgnorePath '/.btrfs'
IgnorePath '/swap'
IgnorePath '/persist'
IgnorePath '/data'
IgnorePath '/mnt'

# Logs and temporary state
IgnorePath '/var/log'
IgnorePath '/var/log/*'
IgnorePath '/var/tmp'
IgnorePath '/var/db/sudo'

# Generated boot artifacts
IgnorePath '/boot/vmlinuz-*'
IgnorePath '/boot/initramfs-*.img'
IgnorePath '/boot/*-ucode.img'
IgnorePath '/efi'

# Generated certificate stores
IgnorePath '/etc/ca-certificates/extracted'
IgnorePath '/etc/ssl/certs'

# Pacman keyring runtime state
IgnorePath '/etc/pacman.d/gnupg'

# Package database caches
IgnorePath '/var/lib/pacman/local'
IgnorePath '/var/lib/pacman/sync'

# Generated caches and indexes
IgnorePath '/etc/ld.so.cache'
IgnorePath '/usr/lib/gconv/gconv-modules.cache'
IgnorePath '/usr/lib32/gconv/gconv-modules.cache'
IgnorePath '/usr/lib/locale/locale-archive'
IgnorePath '/usr/lib/modules/*/modules.*'
IgnorePath '/usr/lib/udev/hwdb.bin'
IgnorePath '/usr/share/info/dir'
IgnorePath '/usr/lib/gio/modules/giomodule.cache'
IgnorePath '/usr/share/glib-2.0/schemas/gschemas.compiled'

# systemd runtime/persistent state that is not configuration
IgnorePath '/var/lib/systemd/backlight'
IgnorePath '/var/lib/systemd/catalog'
IgnorePath '/var/lib/systemd/coredump'
IgnorePath '/var/lib/systemd/ephemeral-trees'
IgnorePath '/var/lib/systemd/nvpcr'
IgnorePath '/var/lib/systemd/pstore'
IgnorePath '/var/lib/systemd/random-seed'
IgnorePath '/var/lib/systemd/rfkill'
IgnorePath '/var/lib/systemd/timers'
IgnorePath '/var/lib/systemd/tpm2-srk-public-key.*'

# Generated or runtime system state
IgnorePath '/var/lib/libuuid'
IgnorePath '/var/lib/machines'
IgnorePath '/var/lib/portables'
IgnorePath '/var/lib/private'
IgnorePath '/var/lib/systemd/linger'
IgnorePath '/var/lib/systemd/network'
IgnorePath '/var/lib/tpm2-tss'

# Downloaded firmware metadata, update state, and fwupd client identity
IgnorePath '/var/lib/fwupd'
IgnorePath '/var/lib/fwupd/*'

# Passim firmware-metadata cache and its generated TLS identity
IgnorePath '/var/lib/passim'
IgnorePath '/var/lib/passim/*'

# Login/accounting databases
IgnorePath '/var/lib/lastlog'

# Timestamp marker files
IgnorePath '/etc/.updated'
IgnorePath '/var/.updated'

# Transient lock/state
IgnorePath '/etc/.pwd.lock'

# NetworkManager runtime state
IgnorePath '/var/lib/NetworkManager'

# Dynamically generated networking configuration
IgnorePath '/etc/resolv.conf'
IgnorePath '/etc/pacman.d/mirrorlist'

# Generated shell registry
IgnorePath '/etc/shells'

# Machine identity
IgnorePath '/etc/machine-id'
IgnorePath '/var/lib/dbus/machine-id'
IgnorePath '/etc/os-release'
IgnorePath '/usr/lib/os-release'

# SSH host identity (public & private keys)
IgnorePath '/etc/ssh/ssh_host_*'

# DKMS signing identity (public & private keys)
IgnorePath '/var/lib/dkms/mok.*'

# Machine-specific system identity and state
IgnorePath '/etc/hostname'
IgnorePath '/etc/adjtime'

# Mimetype definitions
IgnorePath '/usr/share/mime/*'

# Locally signed package-derived binary
IgnorePath '/usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed'

# Local account databases
IgnorePath '/etc/passwd'
IgnorePath '/etc/group'
IgnorePath '/etc/shadow'
IgnorePath '/etc/gshadow'
IgnorePath '/etc/subuid'
IgnorePath '/etc/subgid'

# Account database backup files
IgnorePath '/etc/passwd-'
IgnorePath '/etc/group-'
IgnorePath '/etc/shadow-'
IgnorePath '/etc/gshadow-'
IgnorePath '/etc/subuid-'
IgnorePath '/etc/subgid-'

# Audit configuration
IgnorePath '/etc/audisp'
IgnorePath '/etc/audit/plugins.d'
IgnorePath '/etc/audit/rules.d'

# Docker / Podman state
IgnorePath '/var/lib/docker'
IgnorePath '/var/lib/containerd'
IgnorePath '/var/lib/conteainers'
IgnorePath '/var/lib/cni'

# Sensitive files
IgnorePath '/etc/NetworkManager/system-connections'
IgnorePath '/var/lib/sbctl'
