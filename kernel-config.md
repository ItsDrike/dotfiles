# Kernel configuration guide

This file contains all of the changes I made from default
gentoo-sources kenrel in menuconfig. I listed them here to make
it simple to independently configure other machines.

## Configuration listing

- General Setup
    - Kernel compression mode: LZ4
    - uselib syscall: N
    - Kernel log buffer size: 45
    - CPU kernel log buffer size contribution: 45
    - Temporary per-CPU printk log buffer size: 12
    - Compiler optimization level: Optimize for performance -O2
- Processor type and features
    - Enable MPS table: N
    - Support for extended (non-PC) x86 platforms: N
    - Processor family: Core2/newer Xeon
    - Maximum number of CPUs: 8 # CPU threads amount
    - Multi-core scheduler support: N
    - Reroute for broken boot IRQs
    - Machine Check / overheating reporting
        - AMD MCE features: N
    - Performance monitoring
        - AMD Processor Power Reporting Mechanism: N
    - IOPERM and IPPL Emulation: N
    - CPU mircocode loading support
        - AMD microcode loading support: N
    - Enable 5-level page tables support
    - Check for low memory corruption: N
    - MTRR (Memory Type Range Register) support
        - MTRR cleanup enable value: 1
        - MTRR cleanup spare reg num: 1
- Power management and ACPI options
    - CPU Frequency scaling
        - Default CPUFreq governor: ondemand
        - 'performance' governor: *
        - 'powersave' governor: *
        - 'userspace' governor for userspace fequency scaling: N
        - 'ondemand' cpufreq policy governor: *
        - 'conservative' cpufreq governor: N
        - 'schedutil' cpufreq policy governor: *
    - Cpuidle Driver for Intel Processors: *
- Virtualization
    - Kernel-based Virtual Machine (KVM) support: *
        - KVM for Intel (and compatible) processors support: *
- Enable loadable module support
    - Module unloading
        - Forced module unloading: N
- Enable the block layer
    - Block layer debugging information in debugfs: N
- IO Schedulers
    - MQ deadline I/O scheduler: N
    - Kyber I/O scheduler: N
    - BFQ I/O scheduler: *
- Networking support
    - Wireless
        - cfg80211 - wireless connfiguration API: M
            - enable powersave by default
        - Generic IEEE 802.11 Networking Stack (mac80211): M
    - Networking options
        ## TODO: Check these options and configure them specifically
        - TCP/IP networking
            - The IPv6 protocol
                - IPv6-in-IPv4 tunnel (SIT driver): N
    - Bluetooth subsystem support: *
- Device Drivers
    - Generic Driver Options
        - Firmware loader
            # Let kernel compile the firmware here into the kernel, otherwise
            # you would need to set those dirvers as modules, instead of building
            # into the kernel. It doesn't really affect me to leave them as
            # modules. This option also caused me problems so I don't set it.
            - Build named firmware blobs into the kernel binary: /lib/firmware
    - Block devices
        - Loopback device support: *  # enable reading cd-roms
        - Number of loop devices to pre-create at init time: 0
    - SCSI device support
        - SCSI disk support: *
        - SCSI CDROM support: *
        - Asynchronous SCSI scanning: *
    - Serial ATA and Parallel ATA drivers
        ## TODO: Consider disabling ATA SFF support, could cause problems though
    - Multiple devices driver support: *
        - Device mapper support: *
            - Crypt target support: *
            - Thin provisioning target: *
    - Macintosh device drivers: N
    - Network device support
        - Ethernet driver support
            - Atheros devices
                - Atheros Qualcomm AR816x/AR817x support
            ## Turn off everything else. NOTE: this depends on HW
        - Wireless LAN
            - Atheros/Qualcomm devices
                - Atheros 802.11ac wireless cards support: M
                    - Athernos ath10k PCI support: M
            ## Turn off everything else. NOTE: this depends on HW
        - USB Network Adapters: N
    - Input device support
        - Keyboards:
            - AT keyboard: *
        - Mice:
            - PS/2 mouse: *
            - Synaptics I2C Touchpad support: *
        - Joysticks/Gamepads: N
        - Tablets: N
        - Touchscreens: N
    - Hardware Monitoring support
        - Intel Core/Core2/Atom temperature sensor: *
    - Multifunction device drivers
        - Intel Quark MFD I2C GPIO: *
        - Intel ICH LPC: *
        - Intel SCH LPC: *
        - Intel Low Power Subsystem support in ACPI mode: *
        - Intel Low Power Subsystem support in PCI mode: *
        - Intel PMC Dirver for Broxton: *
        - Intel Platform Monitoring Technology (PMI) support: *
    - Graphics support
        - Maximum number of GPUs: 2
    - Sound card support
        - Advanced Linux Sound Architecture
            - PCI sound devices:
                - [TODO Check if needed] Intel/SiS/nVidia/AMD/ALi AC97 Controller: *
            - HD-Audio
                - Build HDMI/DisplayPort HD-audio codec support: *
                - Build Conexant HD-audio codec support: *
            - USB sound devices:
                - USB Audio/MIDI driver: *
    - HID support
        - Special HID drivers
            ## Configure these based on HW
            ## For touchpads, add
            - HID Multitouch panels
        # This is also required for touchpads
        - I2C HID support
            - HID over I2C transport layer ACPI driver
    - x86 Platform Specific Device drivers
        ## These are mostly for laptop specific things (vol up/down, etc.)
- File systems
    - The extended 4 filesystem: *
    - Btrfs filesystem support: *
        - Btrfs POSIX Access Control Lists: *
    - FUSE (Filesystem in Userspace) support: * # for androind connection with MTP
    - CD-ROM/DVD Filesystems:
        - ISO 9660 CDROM file system support: M
        - Microsoft Joliet CDROM extensions: *
        - Transparent decompression extension: *
        - UDF file system support: M
    - DOS/FAT/EXFAT/NT Filesystems
        - MSDOS fs support: *
        - VFAT (Windows-95) fs support: *
        - exFAT filesystem support: *
        - NTFS file system support: *
            - NTFS write support: *
    - Miscellaneous filesystems: N
    - Network File Systems: *
- Security options
    - NSA SELinux Support: N
    - AppArmor Support: *
