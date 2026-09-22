# Kernel, firmware, drivers

AddPackage linux # The Linux kernel and modules
AddPackage linux-headers # Headers and scripts for building modules for the Linux kernel
AddPackage linux-cachyos # The Linux EEVDF + LTO + AutoFDO + Propeller Cachy Sauce Kernel by CachyOS with other patches and improvements. kernel and modules
AddPackage linux-cachyos-headers # Headers and scripts for building modules for the Linux EEVDF + LTO + AutoFDO + Propeller Cachy Sauce Kernel by CachyOS with other patches and improvements. kernel
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

# Extend mkinitcpio hooks configuration, adding sd-encrypt
CopyFile /etc/mkinitcpio.conf.d/10-hooks.conf

# Update the mkinitcpio presets to build UKIs
CopyFile /etc/mkinitcpio.d/linux-cachyos.preset
CopyFile /etc/mkinitcpio.d/linux.preset

# Default kernel command line (baked into the UKIs)
# The cmdline can be extended per-host with /etc/cmdline.d entries
CopyFile /etc/kernel/cmdline
