# Installation

This installation guide will walk you through the process of setting up Arch
Linux, getting you from live cd to a working OS.

This guide is written primarily as a reference for myself, but it can certainly
be a useful resource for you too, if you want to achieve a similar setup.

This guide includes steps for full disk encryption, and sets up the system with
some basic tools and my zsh configuration.

## Internet

If you're using ethernet, you can skip this part, it focuses on Wi-Fi.

To connect to Wi-Fi from the installation ISO system, run `iwctl`. From there, run:

```bash
device list
# Find the device you're interested in, usually something like wlan0
# Also take notice of the adapter name that this device uses
#
# Before anything else, make sure to power on the device and the adapter
device [device] set-property Powered on
adapter [adapter] set-property Powered on
# Now put the device into a scan mode and get the results
# You can skip this part if you know the SSID
station [device] scan
station [device] get-networks
# Find the SSID of the network you're interested
station [device] connect "[SSID]"
# You'll be prompted for a password, enter it, then you should get connected
# To leave iwd, press Ctrl+D
```

Finally, let's to sure it worked, run: `ping 1.1.1.1`.

## Partitioning

First thing we will need to do is set up partitions. To do so, I recommend using
`fdisk`. Assuming you have a single-disk system, you will want to create 3
partitions:

- EFI (1 GB)
- Root, Data & Swap (rest)

Some people like to use a swap partition, however, doing so on an otherwise encrypted
system introduces you to unnecessary risk factors, as your swap likely won't be encrypted.
This is especially problematic for hibernation, as hibernating into an unencrypted swap
partition will allow passwordless restore.

Instead, I prefer using a swapfile within BTRFS. This still allows hibernation with
systemd initrd, but only after unlocking the partition.

> [!NOTE]
> Don't forget to also set the type for these partitions (`t` command in `fdisk`).
>
> - EFI partition type: EFI System (1)
> - Root partition type: Linux root x86-64 (23)
> - (Extra) Data partition type: Linux filesystem (20)

### File-Systems

Now we'll to create file systems on these partitions, and give them disk labels:

```bash
mkfs.fat -F 32 /dev/sdX1
fatlabel /dev/sdX1 EFI

cryptsetup luksFormat /dev/sdX3 --label CRYPTFS
cryptsetup open /dev/disk/by-label/CRYPTFS crypfs
mkfs.btrfs -L FS /dev/mapper/cryptfs
```

> [!NOTE]
> For the LUKS encrypted partitions, I'd heavily recommend that you back up the
> LUKS headers in case of a partial drive failure, so that you're still able to
> recover your remaining data. To do this, you can use the following command:
>
> ```bash
> cryptsetup luksHeaderBackup /dev/device --header-backup-file /mnt/backup/file.img
> ```

### BTRFS Subvolumes

Now we will split our btrfs partition into the following subvolumes:

- root: The subvolume for `/`.
- data: The subvolume for `/data`, containing my personal files, which should be
  and backed up.
- snapshots: A subvolume that will be used to store snapshots (backups) of the
  other subvolumes
- swap: A subvolume containing the swap file

```bash
mount /dev/mapper/cryptfs /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/data
btrfs subvolume create /mnt/snapshots
btrfs subvolume create /mnt/swap
btrfs filesystem mkswapfile --size 16g --uuid clear /mnt/swap/swapfile
umount /mnt
```

### Mount the partitions and subvolumes

<!-- markdownlint-disable MD028 -->

> [!NOTE]
> The `compress` mount flag will only affect the newly created files, if you're adding
> this option later on, older files will still remain uncompressed/differently compressed
> on the disk.

> [!NOTE]
> You may have seen others use btrfs options such as `ssd`, `discard=async` and
> `space_cache=v2`. These are all default on modern kernels (with the `ssd` being
> auto-detected), so specifying them is pointless now.

<!-- markdownlint-enable MD028 -->

```bash
mount -o subvol=root,noatime,lazytime,commit=120,compress=zstd:1 /dev/mapper/cryptfs /mnt
mount --mkdir -o subvol=snapshots,noatime,lazytime,commit=120,compress=zstd:1 /dev/mapper/cryptfs /mnt/snapshots
mount --mkdir -o subvol=home,noatime,lazytime,commit=120,compress=zstd:5 /dev/mapper/cryptfs /mnt/data
mount --mkdir -o noatime,lazytime,commit=120,compress=zstd:1 /dev/mapper/cryptfs /mnt/.btrfs
mount --mkdir -o subvol=swap /dev/mapper/cryptfs /mnt/swap

mount --mkdir /dev/disk/by-label/EFI /mnt/efi
mkdir /mnt/efi/arch
mount --mkdir --bind /mnt/efi/arch /mnt/boot

swapon /mnt/swap/swapfile
```

## Base installation

```bash
reflector --save /etc/pacman.d/mirrorlist --latest 10 --protocol https --sort rate
pacstrap -K /mnt base linux linux-firmware linux-headers amd-ucode # or intel-ucode
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

Configure essentials

```bash
pacman -S git btrfs-progs neovim
ln -sf /usr/share/zoneinfo/CET /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen
echo "pc" > /etc/hostname
passwd
```

## Basic configuration

Clone my dotfiles and run the install script

```bash
git clone --recursive https://github.com/ItsDrike/dotfiles ~/dots
cd ~/dots
./install_root.sh
```

Exit and reenter chroot, this time into zsh shell

```bash
exit
arch-chroot /mnt zsh
```

Create non-privileged user

```bash
useradd itsdrike
usermod -aG wheel itsdrike
install -o itsdrike -g itsdrike -d /home/itsdrike
passwd itsdrike
chsh -s /usr/bin/zsh itsdrike
su -l itsdrike # press q or esc in the default zsh options
```

Setup user account

```bash
git clone --recursive https://github.com/ItsDrike/dotfiles ~/dots
cd ~/dots
./install_user.sh
```

Exit (logout) the user and relogin, this time into configured zsh shell

```bash
exit
su -l itsdrike
```

Install LazyVim

```bash
git clone https://github.com/ItsDrike/lazyvim ~/.config/nvim
```

## Fstab adjustments

Finally, we'll want to make some slight modifications to `/etc/fstab` file, so
that we're using labels instead of UUIDs to mount our devices and also fix the
permissions for the EFI mount-point (the fmask & dmask options), as by default,
they're way too permissive. This is how I like to structure my fstab:

<!-- markdownlint-disable MD013 -->

```text
# Static information about the filesystems.
# See fstab(5) for details.
#
# <file system> <dir> <type> <options> <dump> <pass>

# region: Physical partitions

# /dev/nvme1n1p1 LABEL=EFI UUID=A34B-A020
/dev/disk/by-label/EFI     /efi       vfat       rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro   0 2

# /dev/nvme1n1p2 LABEL=SWAP UUID=d262a2e5-a1a3-42b1-ac83-18639f5e8f3d
/dev/disk/by-label/SWAP    none       swap       defaults                                                                                                0 0

# endregion
# region: BTRFS Subvolumes

# /dev/mapper/cryptfs LABEL=FS UUID=bffc7a62-0c7e-4aa9-b10e-fd68bac477e0
/dev/mapper/cryptfs /            btrfs      rw,noatime,compress=zstd:1,subvol=/root         0 1
/dev/mapper/cryptfs /data        btrfs      rw,noatime,compress=zstd:1,subvol=/data         0 2
/dev/mapper/cryptfs /snapshots   btrfs      rw,noatime,compress=zstd:1,subvol=/snapshots    0 2
/dev/mapper/cryptfs /.btrfs      btrfs      rw,noatime,compress=zstd:1                      0 2

# endregion
# region: Bind mounts

# Write kernel images to /efi/arch, not directly to efi system partition (esp), to avoid conflicts when dual booting
/efi/arch      /boot      none       rw,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro,bind  0 0

# endregion
```

<!-- markdownlint-enable MD013 -->

## Ask for LUKS password from initramfs

Ask for encryption password of the root partition in early userspace (only
relevant if you're using LUKS encryption), you'll also need to set cryptdevice
kernel parameter, specifying the device that should be unlocked here, and the
device mapping name. (shown later)

```bash
# Find the line with HOOKS=(...)
# Add `keyboard keymap` after `autodetect` (if these hooks are already there,
# just keep them, but make sure they're after `autodetect`).
# Lastly add `encrypt` before `filesystems`.
nvim /etc/mkinitcpio.conf
```

This will configure `mkinitcpio` to build support for the keyboard input, and
for decrypting LUKS devices from within the initial ramdisk environment.

If you wish, you can also follow the instructions below to auto-enable numlock:

```bash
sudo -u itsdrike paru -S mkinitcpio-numlock
# Go to HOOKS and add `numlock` after `keyboard` in:
nvim /etc/mkinitcpio.conf
```

Now regenerate the initial ramdisk environment image:

```bash
mkinitcpio -P
```

## Configure systemd-boot bootloader

> [!NOTE]
> If you wish to use another boot loader (like GRUB), just follow the Arch Wiki.
> This guide will only cover systemd-boot

### Make sure you're using UEFI

As a first step, you will want to confirm that you really are on a UEFI system.
If you're using any recent hardware, this is very likely the case. Nevertheless,
let's check and make sure:

```bash
bootctl status
```

Make sure the `Firmware` is reported as `UEFI`.

If you're still using BIOS instead of UEFI, you should check the wiki for
instructions on how to set up systemd-boot or choose a different boot manager,
that is more suited for BIOS firmware.

### Install systemd-boot

Install systemd-boot to the EFI system partition (ESP)

```bash
bootctl --esp-path=/efi install
# This might report a warning about permissions for the /efi mount point,
# these were addressed in the fstab file above (changed fmask and dmask),
# if you copied those to your fstab, the permissions will be fixed after reboot
```

Add boot menu entries
(Note that we're using LABEL= for cryptdevice, for which `udev` must be before
the `encrypt` hook in mkinitcpio `HOOKS`. This should however be the case by default.
If you wish, you can also use UUID= or just /dev/XYZ here)

Create a new file - `/efi/loader/entries/arch.conf`, with:

```bash
title Arch Linux
sort-key 0
linux /arch/vmlinuz-linux
initrd /arch/amd-ucode.img
initrd /arch/initramfs-linux.img
options cryptdevice=LABEL=CRYPTFS:cryptfs:allow-discards
options root=/dev/mapper/cryptfs rootflags=subvol=/root
options rw loglevel=3
```

And finally configure loader - `/efi/loader/loader.conf` (overwrite the contents):

```bash
default arch-hyprland.conf
timeout 4
console-mode auto
editor yes
auto-firmware yes
beep no
```

## Reboot

Take a deep breath.

```bash
exit  # go back to live iso (exit chroot)
reboot
```

## Post-setup

Log in as an unpriviledged user, and:

Enable Network Time Protocol (time synchronization)

```bash
sudo timedatectl set-ntp true
timedatectl status
```

Connect to a wifi network

```bash
nmtui
```

## Graphical User Interface

Finally, you can run the `install_gui.sh` script in my dotfiles, to get all of
the packages necessary for a proper graphical experience with Hyprland WM and a
bunch of applications/toolings that I like to use.

This final script is definitely the most opinionated one and you might want to
make adjustments to it, depending on your preferences.

## We're done

If you got this far, good job! You should now be left with a fully functional
Arch Linux system, ready for daily use.

That said, you might find some of the other guides helpful if you wish to tinker
some more:

- If you have more encrypted partitions than just root, you should check out:
  [automounting other encrypted
  partitions](./02_AUTOMOUNTING_ENCRYPTED_PARTITIONS.md).
- You may be also interested in [setting up secure boot](./04_SECURE_BOOT.md).
- Having your encrypted root partition unlock automatically without compromising
  on safety through [tpm unlocking](./06_TPM_UNLOCKING.md).
- The [theming guide](./99_THEMING.md), explaining how to configure qt, gtk,
  cursor and fonts correctly.
- Setting up a display manager (DM) with optional automatic login: [greetd
  guide](./99_GREETD.md)
- On laptops, you should check the [battery optimizations
  guide](./99_BATTERY_OPTIMIZATIONS.md)
