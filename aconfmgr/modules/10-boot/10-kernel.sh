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
