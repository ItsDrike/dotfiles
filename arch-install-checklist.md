# Arch installation checklist
This file contains simplified instructions for Arch Linux installation
Following these should lead to a full installation of barebone Arch system,
with grub bootloader and a priviledged sudoer user.

Note: Running the script can automated many of these points, if you are comming
here after running the script, look for a line saying: **Proceed from this line, if you're reading after chrooting**
## Set keyboard layout
Default layout will be US
`ls /usr/share/kbd/keymaps/**/*.map.gz` <- list keymaps
`loadkeys de-latin1` <- modify layout

## Verify boot mode
`ls /sys/firmware/efi/efivars` <- if exist, system is UEFI, else legacy BIOS

## Internet connection
Ethernet connection is automatic, WiFi:
`ip link` <- check network interface works and is enabled
`iwctl` <- authenticate to your WiFi network

`ping archlinux.org` <- test connection

## System clock
`timedatectl set-ntp true` <- make sure the clock will be accurate
`timedatectl status` <- check the status

## Partition the disk
`fdisk /dev/sdX` <- make partitions
- EFI (if UEFI)
- Swap
- Root
- (Home)

## Format the partitions and make filesystems
`mkfs.ext4 /dev/root_partition`
`mkfs.fat -F32 /dev/efi_system_partition`
`mkswap /dev/swap_partition`

## Mount the file systems
`mount /dev/root_partition /mnt`
`mount /dev/efi_system_partition /mnt/boot`
`swapon /dev/swap_partition`

## Install essentials
First select mirrors (`/etc/pacman.d/mirrorlist`)
`pacstrap /mnt base linux linux-firmware base-devel NetworkManager vim`

## Fstab
`genfstab -U /mnt >> /mnt/etc/fstab`

## Chroot
`arch-chroot /mnt`
# Proceed from this line, if you're reading after chrooting

## Set time zone
`ln -sf /usr/share/zoneinfo/Region/Ciry /etc/localtime` <- specify timezone
`hwclock --systohc` <- synchronize clock, to generate `/etc/adjtime`

## Localization
Edit `/etc/locale.gen` and uncomment `en_US.UTF-8 UTF-8` and ISO locales
`locale-gen` <- Generate locales

Set LANG variable in `locale.conf`:
```
LANG=en_US.UTF-8
```

Set persistent keyboard layout in `/etc/vconsole.conf`
(This will default to english, if not set)
```
KEYMAP=de-latin1
```

## Network Config
Define hostname in `/etc/hostname` (name of computer)
Add matching entries to `/etc/hosts`
```
127.0.0.1	localhost
::1			localhost
127.0.1.1	hostname.localdomain	hostname
```

## Set root password or make other account
`passwd` <- Set root password

It's better to work with priviledged user rather than root account directly.
To do this, we first have to install `sudo` and `vim`. (We did this with `pacstrap`)
After that, we can edit the configuration by `sudo EDITOR=vim visudo`, in which we will uncomment the line `%wheel ALL=(ALL) ALL` and save

After sudo is set up and `wheel` group is allowed to use it, we can make the user:
`useradd -G wheel,admin -d /path/to/home -m username -`
`passwd username`

After this, we can login as this user and make sure everything works as it shoud:
`sudo su username`

## Install bootloader
This will only cover grub, for other bootloaders, visit `https://wiki.archlinux.org/index.php/Arch_boot_process#Boot_loader`

Install `grub` package with pacman
Note: To detect other operating systems too, you will also need `os-prober` package, also with NTFS systems, if windows isn't detected, try installing `ntfs-3g` and remounting


UEFI:
`efibootmgr` package is also needed for UEFI systems
`grub-install --target=x86_64-efi --efi-directory=boot --bootloader-id=GRUB`
BIOS (Legacy):
`grub-install --target=i386-pc /dev/sdX`, where sdX is the disk, **not a partition**

Note: `--removable` option can be used, which will allow booting if EFI variables are reset or you move to another PC

### Generating grub configuration
`grub-mkconfig -o /boot/grub/grub.cfg`
