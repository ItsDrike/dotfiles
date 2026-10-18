# Extend mkinitcpio hooks configuration, adding Plymouth and sd-encrypt.
CopyFile /etc/mkinitcpio.conf.d/10-hooks.conf

# Enable numlock before the initrd's LUKS password / TPM pin prompt
AddPackage kbd # Console keyboard utilities; provides setleds for the initrd numlock service
CopyFile /etc/initcpio/install/sd-numlock 755
CopyFile /usr/lib/systemd/system/initrd-numlock.service

# HACK: Plymouth NumLock auto-activation workaround
#
# This emits an actual Numlock key-press from the keyboard device to Plymouth,
# as plymouth currently doesn't respect the NumLock LED state (which the unit
# above sets and is the standard way to do this generically).
#
# This hack MUST be removed once the upstream fixes this issue (otherwise, it
# will have the opposite effect - it would disable NumLock)
# Ref: <https://gitlab.freedesktop.org/plymouth/plymouth/-/work_items/357>
AddPackage evemu # Provides evemu-event for the Plymouth NumLock-state workaround
CopyFile /etc/initcpio/install/sd-plymouth-numlock 755
CopyFile /usr/lib/initcpio/plymouth-numlock-toggle 755
CopyFile /usr/lib/systemd/system/initrd-plymouth-numlock.service

# Update the mkinitcpio presets to build UKIs
CopyFile /etc/mkinitcpio.d/linux-cachyos.preset
CopyFile /etc/mkinitcpio.d/linux.preset
