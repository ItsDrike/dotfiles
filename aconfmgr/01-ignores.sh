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

# Generated certificate stores
IgnorePath '/etc/ca-certificates/extracted'
IgnorePath '/etc/ssl/certs'

# Generated caches and indexes
IgnorePath '/etc/ld.so.cache'
IgnorePath '/usr/lib/gconv/gconv-modules.cache'
IgnorePath '/usr/lib32/gconv/gconv-modules.cache'
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
IgnorePath '/var/lib/systemd/timesync'
IgnorePath '/var/lib/systemd/tpm2-srk-public-key.*'

# Generated or runtime system state
IgnorePath '/var/lib/libuuid'
IgnorePath '/var/lib/machines'
IgnorePath '/var/lib/portables'
IgnorePath '/var/lib/private'
IgnorePath '/var/lib/systemd/linger'
IgnorePath '/var/lib/systemd/network'
IgnorePath '/var/lib/tpm2-tss'

# Timestamp marker files
IgnorePath '/etc/.updated'
IgnorePath '/var/.updated'

# Machine identity
IgnorePath '/etc/machine-id'
IgnorePath '/var/lib/dbus/machine-id'
IgnorePath '/etc/os-release'
IgnorePath '/usr/lib/os-release'

# SSH host identity (public & private keys)
IgnorePath '/etc/ssh/ssh_host_*'

# Machine-specific system identity and state
IgnorePath '/etc/hostname'

# Mimetype definitions
IgnorePath '/usr/share/mime/*'

# Audit configuration
IgnorePath '/etc/audisp'
IgnorePath '/etc/audit/plugins.d'
IgnorePath '/etc/audit/rules.d'

# OpenSMTPD state
IgnorePath '/var/spool/smtpd'

# Font configuration (auto-populated)
IgnorePath '/etc/fonts/conf.d'
