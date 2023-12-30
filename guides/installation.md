# Installation

This is a full Arch Linux installation guide, from live cd to a working OS.
This installation includes steps for full disk encryption, and sets up the
system with some basic tools and my zsh configuration.

## Partition, format and mount the disks

This will depend on your setup, following are the commands I used for my
specific setup as a reference, however you'll very like want a different
disk structure, and you probably won't even have the drives in the same
configuration as I do.

Create partitions for the drives

```bash
fdisk /dev/nvme0n1
# Create new GPT table and make 3 partitions
# first for boot (1G), second for swap (16G),
# third for btrfs (root + /home + data) (rest of the space)

fdisk /dev/nvme0n2
# Create a single partition for btrfs data
```

Format partitions that shouldn't be encrypted

```bash
mkfs.fat -F 32 /dev/nvme0n1p1
fatlabel /dev/nvme0n1p1 EFI
mkswap -L SWAP /dev/nvme0n1p2
```

Format drives using LUKS for encryption and open them to mapper devices

```bash
cryptsetup luksFormat --type luks2 --label ARCH_LUKS /dev/nvme0n1p3
cryptsetup luksFormat --type luks2 --label DATA /dev/nvme0n2p1

cryptsetup luksOpen /dev/disk/by-label/ARCH_LUKS cryptroot
cryptsetup luksOpen /dev/disk/by-label/DATA cryptdata
```

Create BTRFS filesystem on the encrypted drives

```bash
mkfs.btrfs -f -L ARCH /dev/mapper/cryptroot
mkfs.btrfs -f -L DATA /dev/mapper/cryptdata
```

Mount btrfs and create subvolumes

```bash
# Cryptroot
# - We set `noatime` to disable updating of the file access time
#  every time a file is read. This is done for performance improvements,
#  especially on SSDs, and we don't really need to know this information
#  anyway.
# - We set `compress=zstd:1` to enable level 1 zstd compression (lowest),
# which still provides quite fast read/write speeds, while saving some space.
mount -o noatime,compress=zstd:1 /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@       # / (root)
btrfs subvolume create /mnt/@home   # /home
btrfs subvolume create /mnt/@log    # /var/log
btrfs subvolume create /mnt/@cache  # /var/cache
btrfs subvolume create /mnt/@tmp    # /tmp
btrfs subvolume create /mnt/@data   # /data
btrfs subvolume create /mnt/@snapshots
umount /mnt

# cryptdata
# - We use same options for mounting the root btrfs drive as
#  we did for cryptroot here, however we will use a bigger compression
#  rate for the individual subvolumes when mounting them.
mount -o noatime,compress=zstd:1 /dev/mapper/cryptdata /mnt
btrfs subvolume create /mnt/@data     # /data2
btrfs subvolume create /mnt/@backups  # /backups
btrfs subvolume create /mnt/@snapshots
umount /mnt
```

Mount the subvolumes and drives

```bash
# cryptroot btrfs subvolumes
mount -o defaults,noatime,compress=zstd:1,subvol=@ /dev/mapper/cryptroot /mnt
mount -o defaults,noatime,compress=zstd:1,subvol=@home /dev/mapper/cryptroot /mnt/home --mkdir
mount -o defaults,noatime,compress=zstd:2,subvol=@log /dev/mapper/cryptroot /mnt/var/log --mkdir
mount -o defaults,noatime,compress=zstd:3,subvol=@cache /dev/mapper/cryptroot /mnt/var/cache --mkdir
mount -o defaults,noatime,compress=no,subvol=@tmp /dev/mapper/cryptroot /mnt/tmp --mkdir
mount -o defaults,noatime,compress=zstd:5,subvol=@data /dev/mapper/cryptroot /mnt/data --mkdir
# cryptdata btrfs subvolumes
mount -o defaults,noatime,compress=zstd:5,subvol=@data /dev/mapper/cryptdata /mnt/data2 --mkdir
mount -o defaults,noatime,compress=zstd:10,subvol=@backups /dev/mapper/cryptdata /mnt/backups --mkdir
# physical partitions
mount /dev/disk/by-label/EFI /mnt/efi --mkdir
mkdir /mnt/efi/arch-1
mount --bind /mnt/efi/arch-1 /mnt/boot --mkdir
swapon /dev/disk/by-label/SWAP
```

## Base installation

```bash
reflector --save /etc/pacman.d/mirrorlist --latest 10 --protocol https --sort rate
pacstrap -K /mnt base linux linux-firmware linux-headers amd-ucode # or intel-ucode
genfstab -U /mnt >> /mnt/etc/fstab
# Note: We'll need to edit fstab later on, to use UUIDs, and to set proper compression levels
# as the generated options will just use zstd:1 everywhere, the final fstab is shown late.
# during bootloader config
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

Install astronvim

```bash
git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim
git clone https://github.com/ItsDrike/AstroNvimUser ~/.config/nvim/lua/user
```

## Auto-mounting encrypted partitions

We've created a LUKS encrypted partition to store our date into, however it
would be very inconvenient to have to mount it ourselves on each boot. Instead,
we'll probably want to set up a way to mount them automatically. Leaving only
the root partition that we'll need to enter a password for on boot.

### Key files

LUKS encryption has support for multiple keys to the same parition. We'll
utilize this support and add 2nd key slot to all of the partitions that we wish
to auto-mount.

For this 2nd key slot, we will use a key file, as opposed to the regular
user-entered text, so that we can store this key in the file system directly. We
will later be using this stored key to auto-mount. The key file will contain
random data that will be used as the key.

Note that it is very important to have these key files themselves stored on an
encrypted partition, in this case, we're storing them in /etc/secrets, and our
root is encrypted. If you don't have encrypted root partition, it is unsafe to
keep those files in there!

Note that you don't actually need the key files, and if you wish, you can also
be prompted to enter a password on each boot instead (for every partition). You
should prefer this approach if your root partition isn't encrypted, although
know that this can get pretty annoying with more than one encrypted device. If
you wish to do this, you can skip this section.

```bash
exit # Go back to root account
mkdir -p /etc/secrets
dd if=/dev/random bs=4096 count=1 of=/etc/secrets/keyFile-data.bin
chmod -R 400 /etc/secrets
chmod 700 /etc/secrets
```

The bs argument signifies a block size (in bits), so this will create 4096-bit keys.

Now we can add this key into our LUKS encrypted data partition:

```bash
cryptsetup luksAddKey /dev/disk/by-label/DATA --new-keyfile /etc/secrets/keyFile-data.bin
```

### /etc/crypttab

Now that we have the key files ready, we can utilize /etc/crypttab, which
is a file that systemd reads during boot (similarly to /etc/fstab), and contains
instructions for auto-mounting devices.

This is the `/etc/crypttab` file that I use:

<!-- markdownlint-disable MD010 MD013 -->

```txt
# Configuration for encrypted block devices.
# See crypttab(5) for details.

# NOTE: Do not list your root (/) partition here, it must be set up
#       beforehand by the initramfs (/etc/mkinitcpio.conf).

# <name>       <device>                                     <password>              <options>

cryptdata      	 LABEL=DATA         	 /etc/secrets/keyFile-data.bin        	 discard
```

<!-- markdownlint-enable MD010 MD013 -->

If you want to be prompted for the password during boot instead of it being read
from a file, you can use `none` instead of the file path.

The `discard` option is specified to enable TRIM on SSDs, which should improve
their lifespan. It is not necessary if you're using an HDD.

### /etc/fstab

While the crypttab file opens the encrypted block devices and creates the mapper
interfaces for them, to mount those to a concrete directory, we still use
/etc/fstab. Below is the /etc/fstab that I use on my system:

<!-- markdownlint-disable MD010 MD013 -->

```txt
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>

# region: Physical partitions

# /dev/nvme0n1p2 LABEL=SWAP UUID=d262a2e5-a1a3-42b1-ac83-18639f5e8f3d
/dev/disk/by-label/SWAP 	none          	swap      	defaults  	0 0

# /dev/nvme0n1p1 LABEL=EFI  UUID=44E8-EB26
/dev/disk/by-label/EFI  	/efi          	vfat      	rw,relatime,fmask=0137,dmask=0027,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro 	0 2

# endregion
# region: BTRFS subvolumes on /dev/disk/by-label/ARCH (decrypted from ARCH_LUKS)

# /dev/mapper/cryptroot LABEL=ARCH UUID=bffc7a62-0c7e-4aa9-b10e-fd68bac477e0
/dev/mapper/cryptroot	/         	btrfs     	rw,noatime,compress=zstd:1,ssd,space_cache=v2,subvol=/@         	0 1
/dev/mapper/cryptroot	/home     	btrfs     	rw,noatime,compress=zstd:1,ssd,space_cache=v2,subvol=/@home     	0 1
/dev/mapper/cryptroot	/var/log  	btrfs     	rw,noatime,compress=zstd:2,ssd,space_cache=v2,subvol=/@log      	0 1
/dev/mapper/cryptroot	/var/cache	btrfs     	rw,noatime,compress=zstd:3,ssd,space_cache=v2,subvol=/@cache    	0 1
/dev/mapper/cryptroot	/tmp      	btrfs     	rw,noatime,compress=no,ssd,space_cache=v2,subvol=/@tmp          	0 1
/dev/mapper/cryptroot	/data     	btrfs     	rw,noatime,compress=zstd:5,ssd,space_cache=v2,subvol=/@data     	0 2

# /dev/mapper/cryptdata LABEL=DATA UUID=...
/dev/mapper/cryptdata	/data2    	btrfs     	rw,noatime,compress=zstd:5,ssd,space_cache=v2,subvol=/@data     	0 2
/dev/mapper/cryptdata	/backups  	btrfs     	rw,noatime,compress=zstd:10,ssd,space_cache=v2,subvol=/@backups 	0 2

# endregion
# region: Bind mounts

# Write kernel images to /efi/arch-1, not directly to efi system partition (esp), to avoid conflicts when dual booting
/mnt/efi/arch-1 	    /boot     	none      	rw,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro,bind 	0 0

# endregion
```

<!-- markdownlint-enable MD010 MD013 -->

## Bootloader

This guide uses systemd-boot (if you want to use GRUB, just follow the arch wiki).

### Ask for LUKS password from initramfs

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
support for decrypting LUKS devices from within the initial ramdisk
environment.

If you wish, you can also follow the instructions below to auto-enable numlock:

```bash
sudo -u itsdrike yay -S mkinitcpio-numlock
# Go to HOOKS and add `numlock` after `keyboard` in:
nvim /etc/mkinitcpio.conf
```

Now regenerate the initial ramdisk environment image:

```bash
mkinitcpio -P
```

### Configure systemd-boot

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

Create a new file - `/efi/loader/entries/arch-hyprland.conf`, with:

```bash
title Arch Linux (Hyprland)
sort-key 0
linux /arch-1/vmlinuz-linux
initrd /arch-1/amd-ucode.img
initrd /arch-1/initramfs-linux.img
options cryptdevice=LABEL=ARCH_LUKS:cryptroot:allow-discards
options root=/dev/mapper/cryptroot rootflags=subvol=/@
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

**Reboot**

```bash
exit  # go back to live iso (exit chroot)
reboot
```

## Post-setup

Enable Network Time Protocol (time synchronization)

```bash
sudo timedatectl set-ntp true
timedatectl status
```

Connect to a wifi network

```bash
nmtui
```

## Footnotes

Note that this setup is based on my personal system, in which I dual boot
multiple (2) arch instances, one running hyprland, the other running KDE (I
mainly use the hyprland instance, the KDE one is purely there because it's X11
and supports my NVidia card, which Hyprland currenly doesn't).

The config here only really mentions how to get the first (hyprland)
installation ready, however if you wanted to set up both, it's essentially just
doing the same thing again, with some minor changes like in the systemd-boot
entry and some fstab/crypttab entries.

I do plan on writing a continuation guide for how to set up the system for GUI
(Hyprland) too eventually. Once it's done, I will mention it here.
