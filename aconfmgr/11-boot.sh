# Kernel, firmware, drivers

AddPackage linux # The Linux kernel and modules
AddPackage linux-headers # Headers and scripts for building modules for the Linux kernel
AddPackage linux-cachyos # The Linux EEVDF + LTO + AutoFDO + Propeller Cachy Sauce Kernel by CachyOS with other patches and improvements. kernel and modules
AddPackage linux-cachyos-headers # Headers and scripts for building modules for the Linux EEVDF + LTO + AutoFDO + Propeller Cachy Sauce Kernel by CachyOS with other patches and improvements. kernel
AddPackage linux-firmware # Firmware files for Linux - Default set
AddPackage kbd # Console keyboard utilities; provides setleds for the initrd numlock service

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

# Enable numlock before the initrd's LUKS password / TPM pin prompt
CopyFile /etc/initcpio/install/sd-numlock 755
CopyFile /etc/systemd/system/initrd-numlock.service 644
CreateLink \
  /etc/systemd/system/initrd.target.wants/initrd-numlock.service \
  ../initrd-numlock.service

# Update the mkinitcpio presets to build UKIs
CopyFile /etc/mkinitcpio.d/linux-cachyos.preset
CopyFile /etc/mkinitcpio.d/linux.preset

# Default kernel command line (baked into the UKIs)
# The cmdline can be extended per-host with /etc/cmdline.d entries
CopyFile /etc/kernel/cmdline
