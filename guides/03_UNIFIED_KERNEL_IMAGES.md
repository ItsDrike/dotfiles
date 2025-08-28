# Unified Kernel Images (UKI) booting

A Unified Kernel Image is a single executable (`.efi` file), which can be
booted directly from UEFI firmware, or be automatically sourced by boot loaders
with no extra configuration.

> [!NOTE]
> If you're still using BIOS, you will not be able to set up UKIs, they require
> UEFI.

A UKI will include:

- a UEFI stub loader like (systemd-stub)
- the kernel command line
- microcode
- an initramfs image
- a kernel image
- a splash screen

The most common reason why you might want to use UKIs is secure boot. That's
because a UKI is something that can be signed and represents an immutable
executable used for booting into your system.

This is good, because with a standalone bootloader, you would be allowed you to
edit the kernel parameters, or even change the kernel image by editing the
configuration inside of the (unencrypted) EFI partition. This is obviously
dangerous, and we don't want to allow this.

## Define kernel command line

Since UKI contains the kernel command line, we will need to define it so that
when the image is being built, it can pick it up.

This is a crucial step especially when you have encryption set up, as without
it, the kernel wouldn't know what root partition to use.

To set this up, we will use `/etc/kernel/cmdline`.

This is how I setup my kernel arguments (If you're unsure what arguments you
need, just check your current systemd-boot configuration, if you followed [the
INSTALLATION guide](./01_INSTALLATION.md), you will have it in:
`/efi/loader/entries/arch.conf`, all of the `options=` line contain
kernel command line args):

```bash
echo "rw loglevel=3" > /etc/kernel/cmdline
echo "cryptdevice=LABEL=CRYPTFS:cryptfs:allow-discards" >> /etc/kernel/cmdline
echo "root=/dev/mapper/cryptfs rootflags=subvol=/root" >> /etc/kernel/cmdline
```

<!-- markdownlint-disable MD028 -->

> [!TIP]
> If you prefer, you can also create `/etc/kernel/cmdline.d` directory, with
> individual files for various parts of the command line. At the end, all of the
> options from all files in this directory will be combined.
>
> You might find this useful if you set a lot of kernel parameters, so you might
> have for example: `root.conf`, `apparmor.conf`, ...

> [!IMPORTANT]
> Note that you **shouldn't** be specifying the `cryptdevice` or `root` kernel
> parameters if you're using `systemd` initramfs, rather than `BusyBox` one
> (which mkinitramfs generates by default).
>
> That said, you will still need `rootflags` to select the btrfs subvolume
> (unless the root partition is your default subvolume).
>
> If you aren't sure which initramfs you're using, it's probably `BusyBox`.

<!-- markdownlint-disable MD028 -->

## Modify the linux preset for mkinitcpio to build UKIs

Now open `/etc/mkinitcpio.d/linux.preset`, where you'll want to:

- Uncomment `ALL_config`
- Comment `default_image`
- Uncomment `default_uki` (unified kernel image)
- Uncomment `default_options`
- Comment `fallback_image`
- Uncomment `fallback_uki`

## Recreate /efi

First, we'll need to unmount `/boot`, which is currently bind-mounted to
`/efi/EFI/arch`. This is because we'll no longer be storing the kernel,
initramfs, nor the microcode in the EFI partition at all. The EFI partition will
now only contain the final UKI, the rest can be left in `/boot`, which will now
be a part of the root partition, not mounted anywhere.

```bash
umount /boot
vim /etc/fstab  # remove the bind mount entry for /boot
```

Now, we will clear the EFI partition and install `systemd-boot` again from
scratch:

```bash
rm -rf /efi/*
```

Now, we will create a `/efi/EFI/Linux` directory, which will contain all of our
UKIs. (You can change the location in `/etc/mkinitcpio.d/linux.preset` if you
wish to use some other directory in the EFI partition, or you want a different
name for the UKI file. Note that it is recommended that you stick with the same
directory, as most boot loaders will look there when searching for UKIs.)

```bash
mkdir -p /efi/EFI/Linux
```

Finally, we will reinstall the kernel and microcode, re-populating `/boot` (now
on the root partition).

This will also trigger a initramfs rebuild, which will now create the UKI image
based on the `linux.preset` file.

```bash
pacman -S linux amd-ucode # or intel-ucode
```

## Proceeding without a boot manager

Because the Unified Kernel Images can actually be booted into directly from the
UEFI, you don't need to have a boot manager installed at all. Instead, you can
simply add the UKIs as entries to the UEFI boot menu.

> [!NOTE]
> I prefer to still use a full boot manager alongside UKIs, as they allow you to
> have a nice graphical boot menu, from which you can dynamically override the
> kernel parameters during boot, or have extra entries for different operating
> systems, without having to rely on the specific implementation of the boot
> menu in your UEFI firmware (which might take really long to open, or just
> generally not provide that good/clean experience).
>
> Do note though that going without a boot manager is technically a safer
> approach, as it cuts out the middle-man entirely, whereas with a boot manager,
> your UEFI firmware will be booting the EFI image of your boot manager, only to
> then boot your own EFI image, being the UKI.
>
> Regardless, I still like to use `systemd-boot`, instead of booting UKIs
> directly. If you wish to do the same, skip this section.

<!-- markdownlint-disable MD013 -->

```bash
pacman -S efibootmgr
efibootmgr --create --disk /dev/disk/nvme0n1 --part 1 --label "Arch Linux" --loader 'EFI\Linux\arch-linux.efi' --unicode
efibootmgr -c -d /dev/disk/nvme0n1 -p 1 -L "Arch Linux Fallback" -l 'EFI\Linux\arch-linux-fallback.efi' -u
pacman -R systemd-boot
```

<!-- markdownlint-enable MD013 -->

You can also specify additional kernel parameters / override the default ones in
the UKI, by simply adding a string as a last positional argument to the
`efibootmgr` command, allowing you to create entires with different kernel
command lines easily.

## Proceeding with a boot manager

> [!NOTE]
> This is an alternative to the above, see the note in the previous section to
> understand the benefits/cons of either approach.

Most boot managers can handle loading your UKIs. The boot manager of my choice
is `systemd-boot`, but if you wish, you should be able to use grub, or any other
boot manager too. That said, this guide will only mention `systemd-boot`.

All that we'll need to do now is installing systemd-boot, just like during the
initial OS installation:

````bash
```bash
bootctl install --esp-path=/efi
````

If you had some `systemd-boot` settings in your `/efi/loader/loader.conf`, make sure to re-add those, e.g.:

```text
timeout 3
console-mode auto
editor yes
auto-firmware yes
beep no
```

We can now reboot. Systemd-boot will pick up any UKI images in `/efi/EFI/Linux`
automatically (this path is hard-coded), even without any entry configurations.

That said, if you do wish to do so, you can still add an explicit entry for your
configuration in `/efi/loader/entries/arch.conf`, like so:

```text
title Arch Linux
sort-key 0
efi /EFI/Linux/arch-linux.efi
# If you wish, you can also specify kernel options here, it will
# append/override those in the UKI image
#options rootflags=subvol=/@
#options rw loglevel=3
```

Although do note that if your UKI image is stored in `/efi/EFI/Linux`, because
systemd-boot picks it up automatically, you will see the entry twice, so you'll
likely want to change the target directory for the UKIs (in
`/etc/mkinitcpio.d/linux.preset`) to something else.

I however wouldn't recommend this approach, and I instead just let systemd-boot
autodetect the images, unless you need something specific.

If everything went well, you should see a new systemd based initramfs, from
where you'll be prompted for the LUKS2 password.
