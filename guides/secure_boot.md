# Secure boot + TPM unlocking

This guide assumes you already have a working Arch Linux system, set up by following the `installation.md` guide. That means you have an encrypted root partition, and that your computer has a TPM module.

This should mean that currently, every time you boot, you have to enter the LUKS password to decrypt your root partition. This can be pretty annoying though, and this guide aims to fix that, without compromising security.

Once finished, this will basically store the decryption key to your root partition in the TPM module, and so on boot, you'll be able to do so without manually entering your password. This is still perfectly secure, assuming you have a good login screen (in my case, I just use the default linux tty, which I trust fully), and you don't allow anyone to modify the kernel command line (which won't be possible due to secure boot, you'd have to re-sign the images to do so).

So, if the laptop gets stolen, and the drive is pulled out, it's contents will be LUKS encrypted, so the security here is the same. If the attacker boots up the system on the laptop, they will get past encryption, however they'll only see a login screen, and they'd have to also get past linux authentication to actually get anywhere, making this approach safe enough.

## Setup Unified Kernel Image (UKI)

A Unified Kernel Image is a single executable (`.efi` file), which can be booted directly from UEFI firmware, or be
automatically sourced by boot loaders with no extra configuration.

A UKI will include:

- a UEFI stub loader like (systemd-stub)
- the kernel command line
- microcode
- an initramfs image
- a kernel image
- a splash screen

To set up secure boot, this is a requirement, as it's something that can be signed and represents an immutable
executable used for booting into your system.

This is good, because with a standalone bootloader, you would be allowed you to edit the kernel parameters, or even
change the kernel image by editing the configuration inside of the (unencrypted) EFI partition. This is obviously
dangerous, and we don't want to allow this.

### Define kernel command line

Since UKI contains the kernel command line, we will need to define it so that when the image is being built, it can
pick it up.

This is a crucial step especially when you have encryption set up, as without it, the kernel wouldn't know what root
partition to use.

To set this up, we will use `/etc/kernel/cmdline`.

This is how I setup my kernel arguments (If you're unsure what arguments you need, just check your current
systemd-boot configuration, if you followed `installation.md`, you will have it in:
`/efi/loader/entries/arch-hyprland.conf`, all of the `options=` line contain kernel command line args):

```bash
echo "rw loglevel=3" > /etc/kernel/cmdline
echo "cryptdevice=LABEL=ARCH_LUKS:cryptroot:allow-discards" >> /etc/kernel/cmdline
echo "root=/dev/mapper/cryptroot rootflags=subvol=/@" >> /etc/kernel/cmdline
```

Note that you **shouldn't** be specifying the `cryptdevice` or `root` kernel parameters if you're using `systemd`
initramfs, rather than `udev` one (you do still need `rootflags` to select the btrfs subvolume though, unless the
root partition is your default subvolume). (If you haven't messed with it, you will be using `udev` initramfs).

### Modify the linux preset for mkinitcpio to build UKIs

Now open `/etc/mkinitcpio.d/linux.preset`, where you'll want to:

- Uncomment `ALL_config`
- Comment `default_image`
- Uncomment `default_uki` (unified kernel image)
- Uncomment `default_options`
- Comment `fallback_image`
- Uncomment `fallback_uki`

### Recreate /efi

First, we'll need to unmount `/mnt/boot`, which is currently bind mounted to `/efi/EFI/arch-1`. This is because we'll
no longer be storing the kernel, initramfs nor the microcode in the EFI partition at all. The EFI partition will now
only contain the UKI, the rest can be left in `/boot`, which will now be a part of the root partition, not mounted
anywhere.

```bash
umount /boot
vim /etc/fstab  # remove the bind mount entry for /boot
```

Now, we will remove everything in the EFI partition, and start from scratch (this will erase the current systemd-boot configuration, you may want to back it up (`/efi/loader/loader.conf` and `/efi/loader/entries/`))

```bash
rm -rf /efi/*
```

Then, we will reinstall systemd-boot, and create the `/efi/EFI/Linux` directory, which will contain our UKIs. (You
can change this location in `/etc/mkinitcpio.d/linux.preset` if you wish to use some other directory than just
Linux.)

```bash
bootctl install --esp-path=/efi
mkdir -p /efi/EFI/Linux
```

Finally, we will reinstall the kernel and microcode, populating
`/boot` (now on the root partition).

This will also trigger a initramfs rebuild, which will now create the UKI image based on the `linux.preset` file.

```bash
pacman -S linux amd-ucode
```

We can now reboot. Systemd-boot should pick up the UKI images in `/efi/EFI/Linux` automatically, even without any
entry configurations.

If everything went well, you should see a new systemd based initramfs, from where you'll be prompted for

## Secure Boot

Now that we're booting with UKIs, we have images that that we'll be able to sign for secure boot, hence only allowing
us to boot from those images.

However before we can set signing up, we will need to create new signing keys, and upload them into secure boot.

### Enter Setup mode

To allow us to upload new signing keys into secure boot, we will need to enter "setup mode". This should be possible
by going to the Secure Boot category in your UEFI settings, and clicking on Delete/Clear certificates, or there could
even just be a "Setup Mode" option directly.

Once enabled, save the changes and boot back into Arch linux.

```bash
pacman -S sbctl
sbctl status
```

Make sure that `sbctl` reports that Setup Mode is Enabled.

### Create Secure Boot keys

We can now create our new signing keys for secure boot. These keys will be stored in `/usr/share/secureboot` (so in
our encrypted root partition). Once created, we will add (enroll) these keys into the UEFI firmware (only possible
when in setup mode)

```bash
sbctl create-keys
#  the -m adds microsoft vendor key, required for most HW. Not using it could brick your device.
sbctl enroll-keys -m
```

Note: If you see messages about immutable files, run `chattr -i [file]` for all of the listed immutable files, then
re-run enroll-keys command. (Linux kernel will sometimes mark the runtime EFI files as immutable for security - to
prevent bricking the device with just `rm -rf /*`, or similar stupid commands, however since we trust that `sbctl`
will work and won't do anything malicious, we can just remove the immutable flag, and re-running will now work).

### Sign the bootloader and Unified Kernel Images

Finally then, we can sign the `.efi` executables that we'd like to use:

```bash
sbctl sign -s -o /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed /usr/lib/systemd/boot/efi/systemd-bootx64.efi
sbctl sign -s /efi/EFI/BOOT/BOOTX64.EFI
sbctl sign -s /efi/EFI/systemd/systemd-bootx64.efi
sbctl sign -s /efi/EFI/Linux/arch-linux.efi
sbctl sign -s /efi/EFI/Linux/arch-linux-fallback.efi
```

The `-s` flag means save: The files will be automatically re-signed when we update the kernel (via a sbctl pacman
hook). To make sure that this is the case, we can run `pacman -S linux` and check that messages about image
signing appear.

When done, we can make sure that everything that needed to be signed really was signed with:

```bash
sbctl verify
```

### Reboot and enable secure boot

We should now be ready to enable secure boot, as our .efi images were signed, and the signing key was uploaded.

```bash
sbctl status
```

If you see Secure Boot marked as Enabled, it worked!

## Set up TPM unlocking

We'll now set up TPM to take 2 measurements: One of the firmware state, and one of the secure boot state (PCR0 and PCR7). If these remain the same on boot,
the drive will get unlocked. If they've changed, it will fail, and either a recovery key or a password will need to be entered.

```bash
pacman -S tpm2-tss tpm2-tools
```

Verify that your system does actually have a TPM v2 module:

```bash
systemd-cryptenroll --tpm2-device=list
```

Make sure that there is a device listed.

### Switch from udev initramfs to systemd

By default, your initramfs will be using `udev`, however you can instead use `systemd`, which has a bunch of extra
capabilities, such as being able to pick up the key from TPM2 chip.

Open `/etc/mkinitcpio.conf` and find a line that starts with `HOOKS=`

- Change `udev` to `systemd`
- Change `keymap consolefont` to `sd-vconsole`
- Add `sd-encrypt` before `block`, and remove `encrypt`

Additionally, with systemd initramfs, you shouldn't be specifying `root` nor `cryptdevice` kernel arguments, as
systemd can actually pick those up automatically (via systemd-gpt-auto-generator). We will however still need the
`rootflags` argument for selecting the btrfs subvolume (unless your default subvolume is the root partition
subvolume).

So, let's edit our kernel parameters:

```bash
echo "rw loglevel=3" > /etc/kernel/cmdline  # overwrite the existing cmdline
echo "rootflags=subvol=/@" >> /etc/kernel/cmdline
```

You'll also need to modify the `/etc/fstab`, as systemd will not use the `/dev/mapper/cryptroot` name, but rather
you'll have a `/dev/gpt-auto-root` (there'll also be `/dev/gpt-auto-root-luks`, which is the encrypted partition). If
you absolutely insist on using a mapper device, you can also use `/dev/mapper/root` though, which is what systemd
will actually call it.

```bash
vim /etc/fstab
```

We can now regenerate the initramfs with: `pacman -S linux` (we could also do `mkinitcpio -P`, however that won't
trigger the pacman hook which auto-signs our final UKI images, so we'd have to re-sign them with `sbctl` manually)
and reboot to check if it worked.

### Generate recovery key

The following command will generate a new LUKS key and automatically add it to
the encrypted root. You will be prompted for a LUKS password to this device.

This step is optional, as all it does is adding another LUKS keyslot with a generated recovery key, so that in case TPM
wouldn't unlock the drive, you can use this key instead.

You're expected to delete your own key, which is assumed to be less secure than
what this will generate. We will do this after the next step.

If you instead wish to keep your own key working, feel free to skip this step, and the key removal step later.

```bash
systemd-cryptenroll /dev/gpt-auto-root-luks --recovery-key
```

### Enroll the key into TPM

The following command will enroll a new key into the TPM module and add it as a new keyslot of the specified LUKS2 encrypted device.

We also specify `--tpm2-pcrs=0+7`, which selects PCR0 (UEFI firmware status) and PCR7 (Secure Boot status), which will
make sure that if someone updates the UEFI firmware (could mean bypassing the UEFI password), or if someone disables
secure boot, or changes the secure boot keys, the TPM module will not release the encryption key. If this happens, you
will instead be prompted to enter a key manually. You can enter your recovery key here, or if you decided to keep your
original key, you can enter it.

You will be prompted for a LUKS password to this device (you can still enter your original key, you don't need to use
the recovery one, as we haven't deleted the original one yet).

```bash
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/gpt-auto-root-luks
```

This will enroll the TPM2 token token as a key slot 2 for the encrypted drive.

If you're extra paranoid, you can also provide `--tpm2-with-pin=yes`, to prompt for a PIN code on each boot.

To check that it worked, you can use:

```bash
cryptsetup luksDump /dev/gpt-auto-root-luks
```

Make sure that there is an additional LUKS key slot.

### Remove original key

This is an optional step, only follow it if you have generated and properly stored a recovery key.

**Warning:** Make absolutely certain that the recovery key does in fact work before doing this, otherwise, you may get
locked out! You can test your recovery key with:

```bash
cryptsetup luksOpen /dev/gpt-auto-root-luks crypttemp # enter the recovery key
cryptsetup luksClose crypttemp
```

If this worked, proceed to:

```bash
cryptsetup luksRemoveKey /dev/disk/by-label/ARCH_LUKS  # Enter your key to be deleted
```

### Reboot

After a reboot, the system should now get unlocked automatically without prompting for the password.

### Remove key from TPM

In case you'd ever want to remove the LUKS key from TPM, you can do so simply with:

```bash
csystemd-cryptenroll --wipe-slot=tpm2
```

This will actually also remove the LUKS key from the `/dev/gpt-auto-root-luks` device.
