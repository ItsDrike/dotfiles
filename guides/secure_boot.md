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

Then, we will create the `/efi/EFI/Linux` directory, which will contain our UKIs. (You can change this location in
`/etc/mkinitcpio.d/linux.preset` if you wish to use some other directory in the EFI partition, however it is
recommended that you stick with Linux).

```bash
mkdir -p /efi/EFI/Linux
```

Finally, we will reinstall the kernel and microcode, populating
`/boot` (now on the root partition).

This will also trigger a initramfs rebuild, which will now create the UKI image based on the `linux.preset` file.

```bash
pacman -S linux amd-ucode
```

### Boot Manager

This step is optional, because the Unified Kernel Images can actually be booted into directly from the UEFI, if you
wish to do that, you can run the following to add them as entries in the UEFI boot menu:

```bash
pacman -S efibootmgr
efibootmgr --create --disk /dev/disk/nvme0n1 --part 1 --label "Arch Linux (Hyprland)" --loader 'EFI\Linux\arch-linux.efi' --unicode
efibootmgr -c -d /dev/disk/nvme0n1 -p 1 -L "Arch Linux (Hyprland) Fallback" -l 'EFI\Linux\arch-linux-fallback.efi' -u
pacman -R systemd-boot
```

You can also specify additional kernel parameters / override the default ones in the UKI, by simply adding a string as
a last positional argument to the `efibootmgr` command, allowing you to create entires with different kernel command
lines easily.

Doing the above is technically safer than going with a boot manager, as it cuts out the middle-man entirely, however it
can sometimes be nice to have boot manager, as it can show you a nice boot menu, and allow you to modify the kernel
parameters, or add entries for different operating systems very easily, without having to rely on the specific
implementation of the boot menu in your UEFI firmware (which might take really long to open, or just generally not
provide that good/clean experience). Because of that, I like to instead still install the `systemd-boot`. To do so, we can
just install normally with:

```bash
bootctl install --esp-path=/efi
```

We can now reboot. Systemd-boot will pick up any UKI images in `/efi/EFI/Linux` automatically (this path is
hard-coded), even without any entry configurations.

That said, if you do wish to do so, you can still add an explicit entry for your configuration in
`/efi/loader/entries/arch-hyprland.conf`:

```
title Arch Linux (Hyprland)
sort-key 0
efi /EFI/Linux/arch-linux.efi
# If you wish, you can also specify kernel options here, it will
# append/override those in the UKI image
#options rootflags=subvol=/@
#options rw loglevel=3
```

Although do note that if your UKI image is stored in `/efi/EFI/Linux`, because systemd-boot picks it up automatically,
you will see the entry twice, so you'll likely want to change the target directory for the UKIs (in
`/etc/mkinitcpio.d/linux.preset`) to something else.

I however wouldn't recommend this approach, and I instead just let systemd-boot autodetect the images, unless you need
something specific.

If everything went well, you should see a new systemd based initramfs, from where you'll be prompted for the LUKS2
password.

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

(If you're not using `systemd-boot`, only sign the UKI images in `/efi/EFI/Linux`)

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

We'll now set up the TPM module to store a LUKS encryption key for our root partition, which it can release if certain
conditions are met (I'll talk about the specific conditions a few sections later). This will allow us to set it up in
such a way, that allows automatic unlocking without having to enter the password at boot.

This is safe, because set up correctly, TPM will only release the password to unlock the drive if there wasn't any
editing done to the way the system was booted up, in which case we should always end up at a lockscreen after the
bootup, which will be our line of defense against attackers, rather than it being the encryption password itself.

Do make sure that if you go this route, your lockscreen doesn't have any vulnerabilities and can't be easily bypassed.
In my case, I'm using the default linux account login screen, which I do trust is safe enough to keep others without
password out. I also have PAM set up in such a way that after 3 failed attempts, the account will get locked for 10
minutes, which should prevent any brute-force attempts (this is actually the default).

Since TPM is a module integrated in the CPU or the motherboard, so if someone took out the physical drive with the
encrypted data, they would still need to have a LUKS decryption key to actually be able to read the contents of the
root partition.

### Make sure you have a TPM v2 module

```bash
pacman -S tpm2-tss tpm2-tools
```

Verify that your system does actually have a TPM v2 module

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
- If you were using `mkinitcpio-numlock`, also remove `numlock`, it doesn't work with systemd

(As an alternative to `mkinitcpio-numlock`, there is `systemd-numlockontty`, which creates a systemd service that
enables numlock in TTYs after booting (you'll need to enable it), this however doesn't happen in initramfs directly,
only aftwerwars. This shouldn't be too annoying though, as we'lll no longer have to be entering the encryption
password, which is the only reason we'd need numlock in initramfs anyway.)

Additionally, with systemd initramfs, you shouldn't be specifying `root` nor `cryptdevice` kernel arguments, as systemd
can actually pick those up automatically (they'll be discovered by
[systemd-cryptsetup-generator](https://wiki.archlinux.org/title/Dm-crypt/System_configuration#Using_systemd-cryptsetup-generator)
and auto-mounted from initramfs via
[systemd-gpt-auto-generator](https://wiki.archlinux.org/title/Systemd#GPT_partition_automounting)). We will however
still need the `rootflags` argument for selecting the btrfs subvolume (unless your default subvolume is the root
partition subvolume).

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

### Choosing PCRs

PCR stands for Platform Configuration Register, and all TPM v2 modules have a bunch of these registers, which hold
hashes about the system's state. These registers are read-only, and their value is set by the TPM module itself.

The data held by the TPM module (our LUKS encryption key) can then only be accessed when all of the selected PCR
registers contain the expected values. You can find a list of the PCR registers on [Arch
Wiki](https://wiki.archlinux.org/title/Trusted_Platform_Module#Accessing_PCR_registers).

You can look at the current values of these registers with this command:

```bash
systemd-analyze pcrs
```

For our purposes, we will choose these:

- **PCR0**: Hash of the UEFI firmware executable code (may change if you update UEFI)
- **PCR7**: Secure boot state - contains the certificates used to validate each boot application
- **PCR12**: Overridden kernel command line, credentials

> [!IMPORTANT]
> If you're using systemd-boot (instead of booting directly from the UKI images), it is very important that we choose
> all 3, including PCR12, as many tutorials only recommend 0 and 7, which would however lead to a security hole, where
> an attacker would be able to remove the drive with the (unencrypted) EFI partition, and modify the systemd-boot
> loader config (`loaders/loader.conf`), adding `editor=yes`, and the put the drive back in.
>
> This wouldn't violate secure boot, as the `.efi` image files were unchanged, and are still signed, so the attacker
> would be able to boot into the systemd-boot menu, from where they could edit the boot entry for our UKI and modify
> the kernel parameters (yes, even though UKIs contain the kernel command line inside of them, systemd-boot can still
> edit those arguments if `editor=yes`).
>
> From there, the attacker could simply add a kernel argument like `init=/bin/bash`, which would bypass systemd as the
> init system and instead make the kernel run bash executable as the PID=1 (init) program. This would mean you would
> get directly into bash console that is running as root, without any need to enter a password.
>
> However, with PCR12, this is prevented, as it detects that the kernel cmdline was overridden, and so the TPM module
> wouldn't release the key.

The nice thing about also selecting PCR12 is that it will even allow us to securely keep `editor=yes` in our
`loader.conf`, for easy debugging, as all that will happen if we do edit the kernel command line will be that the TPM
module will not release the credentials, and so the initramfs will just ask us to enter the password manually.

### Generate recovery key

The following command will generate a new LUKS key and automatically add it to the encrypted root. You will be prompted
for a LUKS password to this device.

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

We also specify `--tpm2-pcrs=0+7+12`, which selects the PCR registers that we decided on above.

Note: If you already had something in the tpm2 moudle, you will want to add `--wipe-slot=tpm2` too.

You will be prompted for a LUKS password to this device (you can still enter your original key, you don't need to use
the recovery one, as we haven't deleted the original one yet).

```bash
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7+12 /dev/gpt-auto-root-luks
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
