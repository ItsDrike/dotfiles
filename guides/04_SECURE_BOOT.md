# Secure Boot

This guide will show you how to set up UEFI Secure Boot with Arch Linux. Once
finished, you will be left with a system that doesn't allow booting any
untrusted EFI images (other operating systems, fraudulently modified kernels,
...) on your machine.

This guide assumes you're following from the
[INSTALLATION](./01_INSTALLATION.md) guide and that you're using [UNIFIED KERNEL
IMAGES](./03_UNIFIED_KERNEL_IMAGES.md) (UKIs) for booting.

## Security requirements

Meeting these requirements is optional, as it is possible to set up secure boot
without them. That said, if you don't meet these, setting up secure boot will
not be a very effective security measure and it might be more of a time waste
than a helpful means of enhancing your security.

First requirement is to set up a **BIOS Password**. This is a password that you
will be asked for every time you wish to enter the BIOS (UEFI). This is
necessary, as without it, an attacker could very easily just go to the BIOS and
disable Secure Boot.

The second requirement is having **disk encryption**, at least for the root
partition. This is important, because the UEFI signing keys will be stored here,
and you don't want someone to potentially be able to get access to them, as it
would allow them to sign any malicious images, making them pass secure boot.

> [!WARNING]
> Even after following all of these, you should be aware that Secure Boot isn't
> an unbreakable solution. In fact, if someone is able to get a hold of your
> machine, they can simply pull out the CMOS battery, which usually resets the
> UEFI. That means turning off Secure Boot, and getting rid of the BIOS
> password.
>
> While Secure Boot is generally a good extra measure to have, it is by no means
> a reliable way to completely prevent others from ever being able to boot
> untrusted systems, unless you use a specialized motherboard, which persists
> the UEFI state.

## Enter Setup mode

To allow us to upload new signing keys into secure boot, we will need to enter
"setup mode". This should be possible by going to the Secure Boot category in
your UEFI settings, and clicking on Delete/Clear certificates, or there could
even just be a "Setup Mode" option directly.

Once enabled, save the changes and boot back into Arch linux.

```bash
pacman -S sbctl
sbctl status
```

Make sure that `sbctl` reports that Setup Mode is Enabled.

## Create Secure Boot keys

We can now create our new signing keys for secure boot. These keys will be
stored in `/usr/share/secureboot` (so in our encrypted root partition). Once
created, we will add (enroll) these keys into the UEFI firmware (only possible
when in setup mode)

```bash
sbctl create-keys
sbctl enroll-keys -m
```

<!-- markdownlint-disable MD028 -->

> [!WARNING]
> The `-m` option (also known as `--microsoft`) will make sure to also include
> the Microsoft signing keys. This is required by most motherboards, not using
> it could brick your device.

> [!NOTE]
> If you encounter "File is immutable" warnings after running sbctl, it should
> be safe to simply add the `-i` (or `--ignore-immutable`) flag, which will run
> `chattr` and remove the immutable flags from these files for you.
>
> You can also do so manually with `chattr -i [file]` for all the listed
> immutable files and then re-run the enroll-keys command.
>
> This happens because the Linux kernel will sometimes mark the runtime EFI
> files as immutable for security - to prevent bricking the device with just `rm
-rf /*`, or similar stupid commands, however since we trust that `sbctl` will
> work and won't do anything malicious, we can just remove the immutable flag,
> and re-running will now work).
>
> If you still encounter errors even with this flag, it means you have probably
> done something wrong when entering the setup mode. Try looking for a option
> like "Reset keys" in your UEFI, then try this again.

<!-- markdownlint-enable MD028 -->

## Sign the bootloader and Unified Kernel Images

Finally then, we can sign the `.efi` executables that we'd like to use:

```bash
sbctl sign -s -o /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed /usr/lib/systemd/boot/efi/systemd-bootx64.efi
sbctl sign -s /efi/EFI/BOOT/BOOTX64.EFI
sbctl sign -s /efi/EFI/systemd/systemd-bootx64.efi
sbctl sign -s /efi/EFI/Linux/arch-linux.efi
sbctl sign -s /efi/EFI/Linux/arch-linux-fallback.efi
```

(If you're booting directly from UKI images, only sign those - in `/efi/EFI/Linux`)

The `-s` flag means save: The files will be automatically re-signed when we
update the kernel (via a sbctl pacman hook).

> [!TIP]
> To make sure that this is the case, we can run `pacman -S linux` and check
> that messages about image signing appear.
>
> They should look something like this:
>
> ```text
> Signing /efi/EFI/Linux/arch-linux.efi
> ✓ Signed /efi/EFI/Linux/arch-linux.efi
> ...
> Signing /efi/EFI/Linux/arch-linux-fallback.efi
> ✓ Signed /efi/EFI/Linux/arch-linux-fallback.efi
> ...
> File has already been signed /efi/EFI/Linux/arch-linux-fallback.efi
> File has already been signed /efi/EFI/Linux/arch-linux.efi
> File has already been signed /efi/EFI/systemd/systemd-bootx64.efi
> File has already been signed /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed
> File has already been signed /efi/EFI/BOOT/BOOTX64.EFI
> ```

When done, we can make sure that everything that needed to be signed really was
signed with:

```bash
sbctl verify
```

You can also check that setup mode got disabled after enrolling the keys:

```bash
sbctl status
```

Setup mode status should now report as `Disabled`. (Secure boot will still not
appear as enabled though.)

## Reboot with secure boot

We should now be ready to enable secure boot, as our `.efi` images were signed,
and the signing key was enrolled to UEFI firmware. So, all that remains is:

```bash
reboot
```

Boot into UEFI, go to the Secure Boot settings and enable it. (It might get
enabled automatically on some UEFI firmware after setup mode, but it's not
always the case.)

### Verify it worked

To make sure that it worked as expected, and you're booted with secure-boot
enabled, you can now run:

```bash
sbctl status
```

It should report `Secure Boot: enabled` or `Secure Boot: enabled (user)`.

## Why bother?

As I mentioned, secure boot can be bypassed if someone tries hard enough
(pulling the CMOS battery). That then brings to question whether it's even worth
it to set it up, when it doesn't really give you that much.

On its own, I probably wouldn't bother with setting up secure-boot, however
secure boot allows me to set up TPM (Trusted Platform Module) to automatically
release the decryption keys for my LUKS encrypted root partition, in a secure
way. This means I won't have to type my disk password every time I boot which is
actually the primary reason why I like having secure-boot enabled.

For more information on this, check out the follow-up guide:
[TPM_UNLOCKING](./06_TPM_UNLOCKING.md).
