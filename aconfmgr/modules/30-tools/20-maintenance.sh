# System maintenance and diagnostics.
AddPackage arch-audit # A utility like pkg-audit based on Arch Security Team data
AddPackage btop # A monitor of system resources, bpytop ported to C++
AddPackage macchina # A  system information fetcher, with an (unhealthy) emphasis on performance.
AddPackage fwupd # Simple daemon to allow session software to update firmware

# Downloaded firmware metadata, update state, and fwupd client identity.
IgnorePath '/var/lib/fwupd'
IgnorePath '/var/lib/fwupd/*'

# Passim creates these for keeping a signed public firmware metadata
#
# This dir is intended to hold data that can be shared with nearby machines,
# avoiding repeated Internet downloads. Its cache and generated TLS identity
# are mutable.
#
# (We don't currently enable this sharing, but the dirs get automatically
# created when fwupd runs).
IgnorePath '/var/lib/passim'
IgnorePath '/var/lib/passim/*'
