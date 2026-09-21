# Secure Boot

This guide will show you how to set up UEFI Secure Boot with Arch Linux. Once
finished, you will be left with a system that doesn't allow booting any
untrusted EFI images (other operating systems, fraudulently modified kernels,
...) on your machine.

This guide assumes you're following from the
[INSTALLATION](./01_INSTALLATION.md) guide and that you're using Unified Kernel
Images (UKIs) for booting.

## Security requirements

Meeting these requirements is optional, as it is possible to set up secure boot
without them. That said, if you don't meet these, setting up secure boot will
not be a very effective security measure and it might be more of a time waste
than a helpful means of enhancing your security.

First requirement is to set up a **UEFI (BIOS) Password**. This is a password
that you will be asked for every time you wish to enter the UEFI. This is
necessary, as without it, an attacker could very easily just go to the UEFI and
disable Secure Boot.

The second requirement is having **disk encryption**, at least for the root
partition. This is important, because the UEFI signing keys will be stored here,
someone could therefore steal your machine, extract the physical drive, connect
it to their own machine, and steal these signing keys. After that, they would
be able to produce malicious trusted images that your system will accept
booting into (although at this point, they can also already see all of your
data, which you might care about preventing more than someone being able to
boot into your machine).

> [!WARNING]
> Even after following all of these, you should be aware that Secure Boot isn't
> an unbreakable solution. In fact, if someone is able to get a hold of your
> machine, they can simply pull out the CMOS battery, which usually resets the
> UEFI. That means turning off Secure Boot, and getting rid of the UEFI
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
sudo pacman -S sbctl
sudo sbctl status
```

Make sure that `sbctl` reports that Setup Mode is Enabled.

## Create Secure Boot keys

We can now generate our new signing keys for secure boot. These keys will be
stored in `/usr/share/secureboot` (so in our encrypted root partition). They
will be initialized randomly and you should treat them as secrets.

```bash
sudo sbctl create-keys
```

## Sign the bootloader and Unified Kernel Images

Now, we can sign only those `.efi` executables, which we'd like UEFI to allow
us to boot into. Specifically, that means the UKIs, boot manager
(systemd-boot), and the fallback `BOOTX64.EFI` image:

```bash
sudo sbctl sign -s -o \
  /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed \
  /usr/lib/systemd/boot/efi/systemd-bootx64.efi
sudo sbctl sign -s /efi/EFI/BOOT/BOOTX64.EFI
sudo sbctl sign -s /efi/EFI/systemd/systemd-bootx64.efi
sudo sbctl sign -s /efi/EFI/Linux/arch-linux.efi
```

(If you're booting directly from UKI images instead of using systemd-boot, only
sign those (entires in `/efi/EFI/Linux`), this guide assumes sytemd-boot)

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
> File has already been signed /efi/EFI/Linux/arch-linux.efi
> File has already been signed /efi/EFI/systemd/systemd-bootx64.efi
> File has already been signed /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed
> File has already been signed /efi/EFI/BOOT/BOOTX64.EFI
> ```
>
> You can also use `sbctl list-files` or look at `/var/lib/sbctl/files.json`.

When done, we can make sure that everything that needed to be signed really was
signed with:

```bash
sudo sbctl verify
```

## Enroll the keys into the UEFI firmware

Now that we have all of our relevant `.efi` files signed with our new secure
boot keys, we will add (enroll) these keys into the UEFI firmware. (This
operation is only possible when in setup mode).

```bash
sudo sbctl enroll-keys -m
```

<!-- markdownlint-disable MD028 -->

> [!WARNING]
> The `-m` option (or `--microsoft`) enrolls Microsoft's Secure Boot
> certificates alongside the personal keys you just generated. This option
> is **critical** unless you know what you're doing. Not adding it can
> soft-brick your device in certain cases.
>
> The reason why this option may be necessary is because firmware may try to
> load other EFI executables before your personal Linux boot chain. These
> include PCI Option ROMs and UEFI drivers, for example a GPU's GOP/display
> driver. If the firmware rejects required code, the machine might fail to
> initialize a display or device before your bootloader runs.
>
> Recovery would require clearing firmware keys or disabling Secure Boot, which
> however may be difficult (you might be without a graphical display showing
> you what you're doing, or worse, even keyboard input might not work at all).
> It's possible the only option you have would be pulling out the CMOS battery
> to reset the UEFI state (assuming your motherboard doesn't store this state
> permanently).
>
> Some hardware also relies on OEM firmware certificates. `sbctl` can preserve
> the firmware's default certificates with `-f` (or `--firmware-builtin`). This
> is generally less commonly necessary compared to the `-m` option, and usually
> isn't required. For example, for Framework laptops, it is needed if you wish
> to be able to upgrade the firmware and run other boot applications provided
> by OEM.
>
> You should check whether you need to keep the Microsoft, or the OEM keys
> enrolled for your specific device before you proceed. It is generally better
> to include both flags if you're unsure, but it does also mean that you will
> be leaving more potential ways to get into your system.
>
> Note that including Microsoft's certificates means your secure boot config
> will also trust the Windows boot loader, certain recovery tools, and even
> some Linux distribution boot chains. Fedora and Ubuntu installation media
> commonly boot through a Microsoft-signed `shim`. The Arch installation ISO
> however does not support this.
>
> If you find that you need the Microsoft or OEM certificates to load firmware,
> but you don't like the idea of allowing your system to boot these other
> signed media, best you can do is making sure to restrict UEFI boot menu /
> one-time boot option overrides, keeping the internal drive first in the boot
> order, and ideally removing the other boot order entries entirely, to avoid
> fallback. That said, firmware may still discover a fallback path that lets it
> boot into an external drive in some cases. This is unfortunately unavoidable.

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

You can also check that setup mode got disabled after enrolling the keys:

```bash
sudo sbctl status
```

Setup mode status should now report as `Disabled`. (Secure boot will still not
appear as enabled though.)

## Reboot with secure boot

We should now be ready to enable secure boot, as our `.efi` images were signed,
and the signing key was enrolled to UEFI firmware. So, all that remains is:

```bash
sudo reboot
```

Boot into UEFI, go to the Secure Boot settings and enable it. (It might get
enabled automatically on some UEFI firmware after setup mode, but it's not
always the case.)

After you enabled secure boot, boot into Arch Linux.

### Verify it worked

To make sure that it worked as expected, and you're booted with secure-boot
enabled, you can now run:

```bash
sudo sbctl status
# and
sudo bootctl status
```

It should report `Secure Boot: enabled` or `Secure Boot: enabled (user)`.

## Why bother?

As I mentioned, secure boot can be bypassed if someone tries hard enough
(pulling the CMOS battery). That then brings to question whether it's even worth
it to set it up, when it doesn't really give you that much.

On its own, I probably wouldn't bother with setting up secure-boot, however
secure boot allows me to set up TPM (Trusted Platform Module) to automatically
release the decryption keys for my LUKS encrypted root partition, in a secure
way. This means I won't have to type my disk password every time I boot which
is actually the primary reason why I like having secure-boot enabled.

For more information on this, check out the follow-up guide:
[TPM_UNLOCKING](./03_TPM_UNLOCKING.md).
