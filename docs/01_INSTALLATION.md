# Installation

This installation guide will walk you through the process of setting up Arch
Linux, getting you from live cd to a working OS.

This guide is written primarily as a reference for myself, but it can certainly
be a useful resource for others too, if you want to achieve a similar setup to
mine.

The installation guide is split up into multiple chapters which follow each
other. You can skip certain chapters or specific steps, if you wish to deviate
from my specific configuration / preferences.

## Opinionated choices

- **LUKS encryption of root**: The root filesystem is fully LUKS encrypted.
- **UKI (Unified Kernel Images)**: This installation will guide directly
  towards setting up UKIs, meaning instead of having a separate linux image,
  initrd (initramfs) image and microcode in `/boot`, you will have a single
  unified `.efi` image, which can be booted into directly from UEFI (even
  without a bootloader, though we will add one for convenience). Note that if
  you're using a BIOS system, you will not be able to set up UKIs, they require
  UEFI. The biggest reason why you might want to use UKIs is secure boot, as
  UKIs can easily be signed and represents an immutable executable used for
  booting into your system.
- **`systemd-boot` boot manager**: The boot manager of my choice.
- **systemd initrd**: I much prefer using systemd as my initrd, because it has
  various convenience functionalities and handles LUKS decryption easily. This
  is also a requirement for some of the later choices, and has recently became
  the default choice that Arch Linux uses of the box.
- **Impermanence setup**: This setup will guide you towards a setup that allows
  for having impermanence configuration for Arch. This essentially means that
  instead of having a single stable root partition that changes as you change
  your system state, there is instead a stable reference partition (a BTRFS
  snapshot), which the system resets to after every boot. Any changes made to
  the original system will not be retained, unless the reference is explicitly
  updated. This has several side-effects / benefits which are worth explaining:

  - The setup can use several system "generations", which each reflect that
    stable reference, from which the new root is created dynamically on each
    root.
  - A generation must be created in an explicit way. A simple `pacman -Syu`
    system update on the live root for example will not be persisted.
  - You can pick between generations when booting the system, this can often
    save you when an update breaking something in your setup, and making it
    unusable when you don't currently have the time to debug things.
  - This carries a very important advantage, you can install or experiment with
    any programs temporarily, letting them clutter your system in various
    uncontrolled ways, without you having to look for that clutter or do any
    cleanup. Unless you persisted these changes by including them into a
    generation, they will simply disappear after a reboot.
  - There is a distinct separation between system state and user data / configs.
    This configuration makes that explicit in the partitioning (BTRFS
    subvolume) layout. There is a persistent volume, for things you explicitly
    wish to persist across reboots, but without them belonging into the actual
    generations. (Things like browser state - `~/.mozilla` dir.) These dirs
    will automatically lead to the persistent state, through bind mounts
    managed from systemd. Any directory that's not explicitly declared as
    something to be persisted / doesn't lead into a persistent mount point will
    disappear after a reboot, which makes a fresh runtime root from the
    selected generation.

  If you do not wish to have this setup though, you can still follow most of
  this guide regardless, this guide will include a note for where you might
  want to do something differently if you don't wish to use impermanence.

## Internet

> [!NOTE]
> IF you're using Ethernet, you can skip this part, it focuses on Wi-Fi.

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

To get DNS working too, you'll also want to run `dhcpcd`, then you can with
`ping google.com`

> [!TIP]
> At this point, if you have another machine available, I would heavily
> recommend continuing over SSH, that way you can copy commands, and work from
> a much more comfortable environment. If not, continue from the ISO. To be
> able to SSH into the ISO, you will need to set a root password (`passwd`).

## Partitioning

First thing we will do is set up partitions. To do so, I recommend using
`fdisk`.

Assuming you have a single-disk system, you will want to create two partitions
within a GPT partition table:

- EFI (1 GB)
- Root, Data & Swap (rest) - a single BTRFS partition with subvolumes

Some people like to use a standalone swap partition, however, doing so on an
otherwise encrypted system introduces you to unnecessary risk factors, as your
swap won't be encrypted (by default). This is especially problematic for
hibernation, as hibarnating into unencrypted swap partition also allows
passwordless restore.

Instead, I prefer using swap within BTRFS. This still allows hibernation with
systemd initrd, but only after decrypting the partition.

If you have multiple drives, make them every other drive a single-partition
BTRFS with encryption. You can then continue with this guide, and after you
finish (you have arch installed and are able to boot), continue with
[automounting encrypted partitions
guide][automounting-encrypted-partitions-guide], before the other guides.

> [!IMPORTANT]
> Don't forget to also set the type for these partitions (`t` command in `fdisk`).
>
> - EFI partition type: EFI System (1)
> - Root partition type: Linux root x86-64 (23)
> - (Extra) Data partition type: Linux filesystem (20)

### File-System

Now we'll create file systems on these partitions and give them disk labels:

```bash
mkfs.fat -F 32 /dev/sdX1
fatlabel /dev/sdX1 EFI

cryptsetup luksFormat /dev/sdX2 --label CRYPTFS
cryptsetup open /dev/disk/by-label/CRYPTFS cryptfs
mkfs.btrfs -L FS /dev/mapper/cryptfs
```

> [!WARNING]
> Allowing discards through dm-crypt exposes rough filesystem allocation and
> used-space patterns to an offline attacker. It does not expose encrypted file
> contents. This setup accepts that tradeoff to allow periodic SSD TRIM.

> [!NOTE]
> For the LUKS encrypted partitions, I'd heavily recommend that you back up the
> LUKS headers in case of a partial drive failure, so that you're still able to
> recover your remaining data. To do this, you can use the following command:
>
> ```bash
> cryptsetup luksHeaderBackup /dev/sdX2 --header-backup-file /mnt/external-drive/luks-header-backup.img
> ```

Additionally, if you're using SSD (which you likely are), you should
consider enabling discard/TRIM requests to travel through dm-crypt to
the pysical SSD. That way `fstrim` and filessytem discard operations can
tell the SSD which blocks are no longer used, helping the long-term
write performance and wear leveling.

> [!NOTE]
> Technically, there is a small security trade-off for doing this:
>
> Someone with raw access to the encrypted disk could distinguish blocks that
> were discarded from blocks that were not. They still cannot decrypt their
> contents, but may infer approximate used space or filesystem activity.
>
> For a typical personally used encrypted SSD, enabling it is usually a good
> choice.

```bash
cryptsetup refresh --allow-discards --persistent cryptfs
```

After this, you will want to also enable `fstrim.timer` in systemd for
automatic periodic (normally once per week) trimming on all mounted filesystems
that support it. (This is usually preferable over a `discard` mount option, as
it avoids doing discard work synchronously during file deletions.)

### BTRFS Subvolumes

Now we will split our BTRFS partition into the following subvolumes:

```
@bootstrap-root  -> / (temporary initial root, will become the first generation)
@data            -> /data
@persist         -> /persist
@snapshots       -> snapshot storage (automatically taken as backups)
@generations     -> future read-only system generations
@runtimes        -> future current and retained runtime roots
@swap            -> swapfile for hibernation
```

This structure will eventually lead to setting up
[impermanence][impermanence-guide] on Arch Linux, with stable system state
generation snapshots that can be independently booted into for disaster
recovery / (mostly) guaranteed stability.

> [!NOTE]
> If you do not wish to use impermanence, you will want to change the partition
> design to instead be:
>
> - `@bootstrap-root` -> `@root`
> - `@persist` -> X (don't create)
> - `@generations` -> X (don't create)
> - `@runtimes` -> X (don't create)
>
> Other than that, the structure should be identical.

```bash
mount /dev/mapper/cryptfs /mnt
btrfs subvolume create /mnt/@bootstrap-root
btrfs subvolume create /mnt/@data
btrfs subvolume create /mnt/@persist
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@generations
btrfs subvolume create /mnt/@runtimes
btrfs subvolume create /mnt/@swap
btrfs filesystem mkswapfile --size 16g /mnt/@swap/swapfile  # adjust to at least your RAM size
umount /mnt
```

### Mount the partitions and subvolumes

<!-- markdownlint-disable MD028 -->

> [!NOTE]
> You may have seen others use btrfs options such as `ssd`, `discard=async` and
> `space_cache=v2`. These are all default on modern kernels (with the `ssd`
> being auto-detected), so specifying them is pointless now.

> [!NOTE]
> The `compress` mount flag will only affect the newly created files. If you're
> adding this option later on, or changing the compression level, older files
> will still remain in their original compression state on disk unless they are
> explicitly rewritten.
>
> Recompressing existing files requires Btrfs defragmentation. Do this only
> selectively: defragmenting files shared with snapshots or reflinks breaks that
> sharing and can substantially increase disk usage.

> [!IMPORTANT]
> Most Btrfs mount options, including `compress`, apply to the whole filesystem,
> not an individual subvolume. The options from the first mounted subvolume take
> effect, so use the same compression setting for every mount of this Btrfs
> filesystem. A separate Btrfs filesystem, such as an optional separate data
> disk, may use different compression settings.

<!-- markdownlint-enable MD028 -->

Chosen mount flags:

- `noatime`: Do not update a file’s access timestamp whenever it is read. Good
  for Btrfs and snapshots because it avoids otherwise unnecessary metadata COW
  writes. It is also a good choice to reduce disk write wear.
- `lazytime`: Keeps file timestamp updates (`atime`, `mtime`, `ctime`) in
  memory and delays writing them to disk, reducing metadata writes. It might
  result in stale timestamps after an unclean shutdown though.
- `compress=zstd:1`: Transparently compress file data using zstandard at level
  1\. This provides good compression with very low CPU overhead. (It can even
  improve I/O performance sometimes by reducing the amount of data that needs
  to be read/written to disk.)

```bash
mount -o subvol=@bootstrap-root,noatime,lazytime,compress=zstd:1 /dev/mapper/cryptfs /mnt
mount --mkdir -o subvol=@persist,noatime,lazytime,compress=zstd:1 /dev/mapper/cryptfs /mnt/persist
mount --mkdir -o subvol=@data,noatime,lazytime,compress=zstd:1 /dev/mapper/cryptfs /mnt/data

mount --mkdir -o subvol=@swap,noatime,lazytime,compress=zstd:1 /dev/mapper/cryptfs /mnt/swap
swapon /mnt/swap/swapfile

# Mount the top-level BTRFS filesystem as a whole too, under /.btrfs
# This is also how we reach into @snapshots, I don't prefer having /snapshots.
mount --mkdir -o subvolid=5,noatime,lazytime,compress=zstd:1 /dev/mapper/cryptfs /mnt/.btrfs

# Mount the EFI partition under /efi, we'll then generate the UKIs in /efi/EFI/Linux
mount --mkdir /dev/disk/by-label/EFI /mnt/efi
```

## Base installation

```bash
reflector --save /etc/pacman.d/mirrorlist --latest 10 --protocol https --sort rate
pacstrap -K /mnt \
  base linux linux-firmware \
  btrfs-progs cryptsetup networkmanager sudo git neovim \
  amd-ucode # or intel-ucode
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

### Configure essentials

```bash
ln -sf /usr/share/zoneinfo/CET /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen
echo "pc" > /etc/hostname
systemctl enable NetworkManager.service
passwd
```

### Create an unprivileged user

```bash
useradd --create-home --groups wheel --shell /bin/bash itsdrike
passwd itsdrike

# Allow sudo access to anyone in the wheel group
install -Dm440 /dev/stdin /etc/sudoers.d/10-wheel <<'EOF'
%wheel ALL=(ALL:ALL) ALL
EOF

su itsdrike

sudo pacman -S --needed base-devel rustup
rustup default stable
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
rm -rf paru
paru -Syu
```

### Systemd initrd

Configure mkinitcpio hooks to build a systemd based initramfs with the
`sd-encrypt` hook that adds LUKS disk decryption support:

```bash
install -Dm644 /dev/stdin /etc/mkinitcpio.conf.d/10-hooks.conf <<'EOF'
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)
EOF
```

> [!NOTE]
> If you're used to using the numpad for typing numbers, you may find that
> numlock is disabled at the time you're prompted for it. To solve this, we can
> add a custom hook with a systemd service that enables numlock before you're
> asked for the disk password.
>
> <!-- TODO: Numlock guide -->
> **The guide on how to do this is currently work-in-progress.**

Then configure the kernel cmdline, defining which partition / subvolume to
mount into.

> [!NOTE]
> We could set the `rd.luks.name=$(cryptsetup luksUUID /dev/sdX2)=cryptfs` and
> `root=/dev/mapper/cryptfs` kernel params, however, it's actually not
> necessary, because we set our root partition to the `Linux root x86-64` type
> in the GPT partitioning table, and systemd initrd is able to pick up on that
> through it's GPT auto root mechanism. Systemd will then see that it's LUKS
> encrypted and with the `sd-encrypt` hook, you will be prompted for the
> decryption password.

That said, we do need to tell systemd what subvolume to mount, as by default,
it would just attempt to directly mount the decrypted mapper device as-is,
without any mount options, (which would mount the primary btrfs subvolume, not
the `@bootstrap-root`).

> [!TIP]
> Even though we do need to tell systemd which subvolume to mount explicitly,
> we don't really need to tell it what other mount flags we want (things like
> `lazytime,noatime,compress`). This is because after the root gets initially
> mounted, systemd will run `systemd-remount-fs` service, which changes the
> mount options to match the mounted `/etc/fstab`, so this is where we can keep
> those options.
>
> This works even for `compress`, and the remount will in fact enable
> compression on the btrfs parition with the specified mount option. That said,
> if initrd would write into the initially mounted root itself, before this
> remount, those writes would be without compression.

Additionally, we specify the following cmdline args:

- `ro`: this makes the `sysroot.mount` unit mount the root as
  initially read-only. This will only mean that the services running within
  initrd will not be able to make any modifications to the root until it gets
  remounted with the mount options from `/etc/fstab` (in the `systemd-remount-fs`
  service). This is the more secure option, and it prevents initrd writes from
  happening before we have the `compress` option set on btrfs. However, if
  you wish to use some custom initrd hooks that rely on writing into the
  sysroot, this would make those writes fail.
- `loglevel=4`: show kernel logs only up to the warning level verbosity during
  boot. The available values are:

  - `0`: emergency: system is unusable
  - `1`: alert: immediate action needed
  - `2`: critical: serious failure
  - `3`: error
  - `4`: warning
  - `5`: notice
  - `6`: informational
  - `7`: debug (default)

```bash
printf '%s\n' 'ro loglevel=4 rootflags=subvol=@bootstrap-root' > /etc/kernel/cmdline
```

Configure the linux mkinitcpio preset to keep the kernel image
(`/boot/vmlinuz-linux`) inside the encrypted root, and only send the final UKI
to the unencrypted ESP partition:

```bash
install -Dm644 /dev/stdin /etc/mkinitcpio.d/linux.preset <<'EOF'
# mkinitcpio preset file for the 'linux' package

#ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux"
#ALL_kerneldest="/boot/vmlinuz-linux"

PRESETS=('default')
#PRESETS=('default' 'fallback')

#default_config="/etc/mkinitcpio.conf"
#default_image="/boot/initramfs-linux.img"
default_uki="/efi/EFI/Linux/arch-linux-bootstrap.efi"
#default_options="--splash /usr/share/systemd/bootctl/splash-arch.bmp"

#fallback_config="/etc/mkinitcpio.conf"
#fallback_image="/boot/initramfs-linux-fallback.img"
#fallback_uki="/efi/EFI/Linux/arch-linux-fallback.efi"
#fallback_options="-S autodetect"
EOF
```

Build the UKI:

```bash
mkdir -p /efi/EFI/Linux
mkinitcpio -p linux
ls -lh /efi/EFI/Linux/arch-linux.efi
```

## Install systemd-boot

```bash
bootctl --esp-path=/efi install
```

You will likely encounter warnings about `/efi` being world-readable, we can
fix these from fstab, and remount:

```bash
sed -i '\|[[:space:]]/efi[[:space:]]| s|fmask=0022,dmask=0022|fmask=0077,dmask=0077|' /etc/fstab
mount -o remount,fmask=0077,dmask=0077 /efi
```

Now create an optional systemd-boot policy:

```bash
install -Dm644 /dev/stdin /efi/loader/loader.conf <<'EOF'
# Set the default boot entry that gets picked after a reboot to match the
# last previously selected entry.
default @saved
# Show the boot menu for 3 seconds before booting into the selected entry.
timeout 3
# Choose a suitable UEFI console resolution automatically using heuristics.
console-mode auto
# Enabling the editor allows you to modify the kernel cmdline from the boot menu.
# Having this enabled on an unecrypted system without secure boot is very dangerous.
# On an ecrypted system, it is less dangerous, and it can be useful for debugging.
# However, if you will be using secure boot, enabling this will have no effect,
# as even though systemd-boot will let you modify the cmdline, and will emit
# the UEFI LoadOptions with this cmdline modification, the UKI will ignore
# those options, after it detects that it has a signed embedded cmdline
# anyways, so it's really just misleading. For this reason, I just keep it
# disabled from the start.
editor no
# Include the option to go reboot into the firmware settings. auto-firmware yes
# I absolutely, whole-heartedly, hate it when my system beeps at me. Just no.
beep no
EOF
```

Validate the configuration:

```bash
bootctl --esp-path=/efi status
```

## Finishing

Validate the `/etc/fstab`:

```bash
# inspect the contents, make sure they make sense
cat /etc/fstab

# verify the syntax and sources with findmnt
findmnt --verify --verbose --tab-file /etc/fstab
```

Take a deep breath. Then:

```bash
exit
reboot
```

You should see systemd initrd automatically detect the root partition and
prompt you for the decryption password. After entering it, if everything went
well, you will be able to boot into the newly installed system, and log in as
the unprivileged user we created.

## Next steps

At this point, we can continue to customizing the installation.

First of, if you have multiple disks and you set up LUKS encryption on those
too, you should read the [automounting encrypted partitions
guide][automounting-encrypted-partitions-guide].

After that (or if you don't have multiple encrypted partitions), you can move
to setting up secure boot with the [secure boot guide][secure-boot-guide].

[impermanence-guide]: TODO
[automounting-encrypted-partitions-guide]: ./99_AUTOMOUNTING_ENCRYPTED_PARTITIONS.md
[secure-boot-guide]: ./02_SECURE_BOOT.md
