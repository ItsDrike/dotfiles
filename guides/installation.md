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
# Create new GPT table and make 5 partitions
# first for boot (1G), second for swap (16G),
# third for root 1 (100G), fourth for root 2 (100G), fifth for data (rest ~714G)
fdisk /dev/nvme1n1
# Create new GPT table with single partition
fdisk /dev/sda
# Create new GPT table with single partition
```

Format partitions that shouldn't be encrypted

```bash
mkfs.fat -F 32 /dev/nvme0n1p1
fatlabel /dev/nvme0n1p1 BOOT
mkswap -L SWAP /dev/nvme0n1p2
```

Format drives using LUKS for encryption and open them to mapper devices

```bash
cryptsetup luksFormat --label ARCH_ROOT1 /dev/nvme0n1p3
cryptsetup luksFormat --label ARCH_ROOT2 /dev/nvme0n1p4
cryptsetup luksFormat --label DATA /dev/nvme0n1p5
cryptsetup luksFormat --label DATA2 /dev/sda1
cryptsetup luksFormat --label BACKUPS /dev/nvme1n1p1

cryptsetup luksOpen /dev/disk/by-label/ARCH_ROOT1 cryptroot
cryptsetup luksOpen /dev/disk/by-label/ARCH_ROOT2 cryptroot2
cryptsetup luksOpen /dev/disk/by-label/DATA cryptdata
cryptsetup luksOpen /dev/disk/by-label/DATA2 cryptdata2
cryptsetup luksOpen /dev/disk/by-label/BACKUPS cryptbackups
```

Create EXT4 filesystem on the encrypted drives

```bash
mkfs.ext4 -L ARCH_HYPRLAND /dev/mapper/cryptroot
mkfs.ext4 -L ARCH_KDE /dev/mapper/cryptroot2
mkfs.ext4 -L CRYPTDATA /dev/mapper/cryptdata
mkfs.ext4 -L CRYPTDATA2 /dev/mapper/cryptdata2
mkfs.ext4 -L CRYPTBACKUPS /dev/mapper/cryptbackups
```

Mount the drives

```bash
mount /dev/mapper/cryptroot /mnt
mount /dev/disk/by-label/BOOT /mnt/efi --mkdir
mkdir /mnt/efi/arch-hyprland /mnt/efi/arch-kde
mount --bind /mnt/efi/arch-kde /mnt/boot --mkdir
mount /dev/mapper/cryptdata /mnt/mnt/data --mkdir
mount /dev/mapper/cryptdata2 /mnt/mnt/data2 --mkdir
mount /dev/mapper/cryptbackups /mnt/mnt/backups --mkdir
mount /dev/mapper/cryptroot2 /mnt/mnt/arch-kde --mkdir
swapon /dev/disk/by-label/SWAP
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
pacman -S networkmanager neovim sudo reflector pacman-contrib man-db man-pages \
    rsync btop bind tldr git base-devel
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
git clone --recursive https://github.com/dotfiles ~/dots
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
sudo pacman -S luarocks rustup cargo cmake meson npm
rustup default stable
mkdir -p ~/.config/wakatime
git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim
git clone https://github.com/ItsDrike/AstroNvimUser ~/.config/nvim/lua/user
```

## Auto-mounting encrypted partitions

We've create a bunch of LUKS encrypted partitions to store our date into,
however it would be very inconvenient to have to mount them ourselves on each
boot. Instead, we'll probably want to set up a way to mount them automatically.

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

In this example, we'll be creating a different key for every encrypted
partition, but you could also share the same key file for all of them if you
wish. This is however more secure.

```bash
mkdir -p /etc/secrets
dd if=/dev/random bs=4096 count=1 of=/etc/secrets/keyFile-data.bin
dd if=/dev/random bs=4096 count=1 of=/etc/secrets/keyFile-data2.bin
dd if=/dev/random bs=4096 count=1 of=/etc/secrets/keyFile-backups.bin
dd if=/dev/random bs=4096 count=1 of=/etc/secrets/keyFile-arch-hyprland.bin
dd if=/dev/random bs=4096 count=1 of=/etc/secrets/keyFile-arch-kde.bin
chmod -R 004 /etc/secrets
chmod 007 /etc/secrets
```

The bs argument signifies a block size (in bits), so this will create 4096-bit keys.

Now we can add these keys into our LUKS encrypted partitions:

```bash
cryptsetup luksAddKey /dev/disk/by-label/DATA --new-keyfile /etc/secrets/keyFile-data.bin
cryptsetup luksAddKey /dev/disk/by-label/DATA2 --new-keyfile /etc/secrets/keyFile-data2.bin
cryptsetup luksAddKey /dev/disk/by-label/BACKUPS --new-keyfile /etc/secrets/keyFile-backups.bin
cryptsetup luksAddKey /dev/disk/by-label/ARCH_ROOT1 --new-keyfile /etc/secrets/keyFile-arch-hyprland.bin
cryptsetup luksAddKey /dev/disk/by-label/ARCH_ROOT2 --new-keyfile /etc/secrets/keyFile-arch-kde.bin
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
cryptdata2     	 LABEL=DATA2        	 /etc/secrets/keyFile-data2.bin       	 discard
cryptbackups   	 LABEL=BACKUPS      	 /etc/secrets/keyFile-backups.bin     	 discard
cryptarch2     	 LABEL=ARCH_ROOT2   	 /etc/secrets/keyFile-arch-kde.bin    	 discard
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

# region: LUKS encrypted devices (opened from /etc/crypttab, or mounted from initramfs)

/dev/mapper/cryptroot     	 /               	 ext4    	 rw,relatime,nofail,discard     	 0 1
/dev/mapper/cryptdata     	 /mnt/data       	 ext4    	 rw,relatime,nofail,discard     	 0 2
/dev/mapper/cryptdata2    	 /mnt/data2      	 ext4    	 rw,relatime,nofail,discard     	 0 2
/dev/mapper/cryptarch2    	 /mnt/arch-kde   	 ext4    	 rw,relatime,nofail,discard     	 0 2

# endregion
# region: Physical devices

LABEL=BOOT   	 /efi     	 vfat   	 rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro  	0 2
LABEL=SWAP   	 none     	 swap   	 defaults    	 0 0

# endregion
# region: Bind mounts

# Write kernel images to /efi/arch-hyprland, not directly to the efi system partition (esp), to avoid conflicts when dual booting
/efi/arch-hyprland      	 /boot                              	 none  	 rw,bind  	 0 0

# Bind mounts for arch-kde
/efi                    	 /mnt/arch-kde/efi                  	 none  	 rw,bind  	 0 0
/efi/arch-kde           	 /mnt/arch-kde/boot                 	 none  	 rw,bind  	 0 0
/mnt/data               	 /mnt/arch-kde/mnt/data             	 none  	 rw,bind  	 0 0
/mnt/data2              	 /mnt/arch-kde/mnt/data2            	 none  	 rw,bind  	 0 0
/mnt/backups            	 /mnt/arch-kde/mnt/backups          	 none  	 rw,bind  	 0 0
/                       	 /mnt/arch-kde/mnt/arch-hyprland    	 none  	 rw,bind  	 0 0
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
sudo nvim /etc/mkinitcpio.conf
```

This will configure `mkinitcpio` to build support for the keyboard input, and
support for decrypting LUKS devices from within the initial ramdisk
environment.

If you wish, you can also follow the instructions below to auto-enable numlock:

```bash
yay -S mkinitcpio-numlock
# Go to HOOKS and add `numlock` after `keyboard` in:
sudo nvim /etc/mkinitcpio.conf
```

Now regenerate the initial ramdisk environment image:

```bash
sudo mkinitcpio -P
```

### Configure systemd-boot

Install systemd-boot to the EFI system partition (ESP)

```bash
sudo bootctl --esp-path=/efi install
```

Add boot menu entries
(Note that we're using LABEL= for cryptdevice, for which `udev` must be before
the `encrypt` hook in mkinitcpio `HOOKS`. This should however be the case by default.
If you wish, you can also use UUID= or just /dev/XYZ here)

Create a new file - `/efi/loader/entries/arch-hyprland.conf`, with:

```bash
title Arch Linux (Hyprland)
sort-key 0
linux /arch-hyprland/vmlinuz-linux
initrd /arch-hyprland/amd-ucode.img
initrd /arch-hyprland/initramfs-linux.img
options cryptdevice=LABEL=ARCH_ROOT1:cryptroot:allow-discards
options root=/dev/mapper/cryptroot
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
