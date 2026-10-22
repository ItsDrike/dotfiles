###############################################################################
# Kernel images and boot configuration
###############################################################################

AddPackage linux # The Linux kernel and modules
AddPackage linux-cachyos # The Linux EEVDF + LTO + AutoFDO + Propeller Cachy Sauce Kernel by CachyOS with other patches and improvements. kernel and modules

# Generated kernel, initramfs, and microcode boot artifacts.
IgnorePath '/boot/vmlinuz-*'
IgnorePath '/boot/initramfs-*.img'
IgnorePath '/boot/*-ucode.img'
IgnorePath '/efi'
IgnorePath '/usr/lib/modules/*/modules.*'

# Universal kernel command line baseline (baked into the UKIs).
# Modules and hosts add their own parameters with /etc/cmdline.d/*.conf.
CopyFile /etc/kernel/cmdline

# fbcon is the kernel's framebuffer-backed virtual console driver. It's what
# gives a TTY its text grid. This configures it to take over the first usable
# framebuffer immediately as soon as KMS is available, rather than deferring
# takeover until some console output is actually first written. (KMS is Kernel
# Mode Setting - API that a kernel graphics driver provides once initialized.)
#
# We do this to prevent visual artifacts connected to re-scaling right after
# boot, caused by The kernel initially using a 80 col x 25 row dummy console
# before switching to a real framebuffer and recalculating the terminal's text
# grid.
#
# This is most noticeable for easly text-based interfaces, like agetty or
# greetd's tuigreet. Without early framebuffer takeover, their first output
# would initially use the dummy console, with the write triggering the switch,
# which then triggers the app to redraw itself. That results in the interface
# getting rescaled or re-centered.
printf '%s\n' 'fbcon=nodefer' > "$(CreateFile /etc/cmdline.d/40-fbcon.conf)"

###############################################################################
# DKMS / out-of-tree kernel modules
###############################################################################

AddPackage linux-headers # Headers and scripts for building modules for the Linux kernel
AddPackage linux-cachyos-headers # Headers and scripts for building modules for the Linux EEVDF + LTO + AutoFDO + Propeller Cachy Sauce Kernel by CachyOS with other patches and improvements. kernel

# DKMS-generated Machine Owner Key (MOK) material
#
# Used to sign out-of-tree kernel modules so they can load when kernel lockdown
# requires trusted module signatures. Secure Boot commonly enables this kernel
# policy: the loaded kernel validates modules, using keys it trusts via the MOK
# chain. Regardless of secure boot status though, DKMS will always generate and
# sign the modules by default.
IgnorePath '/var/lib/dkms/mok.*'

###############################################################################
# Firmware / Drivers
###############################################################################

AddPackage linux-firmware # Firmware files for Linux - Default set

# Install microcode packages dynamically based on the running CPU vendor
case "$(uname -m)" in
    x86_64)
        if grep -q GenuineIntel /proc/cpuinfo; then
            AddPackage intel-ucode # Microcode update files for Intel CPUs
        elif grep -q AuthenticAMD /proc/cpuinfo; then
            AddPackage amd-ucode # Microcode update image for AMD CPUs
        fi
        ;;
esac

###############################################################################
# Kernel module policy
###############################################################################

# Disable the legacy PC speaker bell in the initrd and the running system.
# (I would rather physically remove the motherboard speaker than have my
# system beep at me, luckily, we can disable it from software)
CopyFile /etc/modprobe.d/nobeep.conf
