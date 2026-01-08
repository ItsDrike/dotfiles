# TPM Unlocking

This will explain how to set up TPM (Trusted Platform Module) based automatic
unlocking of your LUKS encrypted partition(s). Encryption usually requires that
you manually type the password in each time you boot. This can however be pretty
annoying (especially if you use a long password, like I do). This guide aims to
fix this problem, without compromising security.

Once finished, this will basically store another decryption key(s) to your
encrypted partition(s) in the TPM module. During boot, while in initrd, we will
request this decryption key from TPM, which will only release it under certain
conditions, to ensure safety.

The guide assumes you have already a working Arch Linux system, that uses LUKS
encryption, having followed the [INSTALLATION guide](./01_INSTALLATION.md). You
will also need to set up secure-boot, as described in
[SECURE_BOOT](./04_SECURE_BOOT.md). This is a requirement, as while it is
possible to set up TPM unlocking without it, doing so is incredibly insecure,
and might lead to unauthorized users getting TPM to release your decryption
keys. Additionally, you will need to be using a [SYSTEMD BASED
INITRAMFS](./05_SYSTEMD_INITRAMFS.md), as the default BusyBox one doesn't
support TPM unlocking.

> [!WARNING]
> This solution will be mostly safe, however, it is technically possible to hook
> up wires to the motherboard, to listen to the communication coming from the
> TPM chip. In that case, the attacker would be able to observe the key as it
> gets released by the chip. They could then take out your SSD/HDD, and mount it
> on their machine, using these obtained keys to decrypt the contents. See:
> <https://astralvx.com/stealing-the-bitlocker-key-from-a-tpm/>
>
> If you can't afford to be vulnerable to this type of attack, you can still
> follow through with this, however instead of the TPM seamlessly releasing the
> decryption password, you can require a password to be entered, without which
> TPM won't release the decryption password. This will be explained later.
>
> This can be useful if you use a very long encryption passwords, and you want
> to be able to enter a shorter passphrase instead (TPM has brute-force
> protection, so a short password isn't actually that unsafe to use). I'm
> personally using this approach on my devices.

## Check if you actually have the TPM module

First, you will want to verify that your machine even has the TPM v2 module. To
do so, you can use the following command:

```bash
bootctl status
```

You should see `TPM2 Support: yes` in the output.

## Choosing PCRs

PCR stands for Platform Configuration Register, and all TPM v2 modules have a
bunch of these registers, which hold hashes about the system's state. These
registers are read-only, and their value is set by the TPM module itself.

The data held by the TPM module (our LUKS encryption key) can then only be
accessed when all of the selected PCR registers contain the expected values. You
can find a list of the PCR registers on [Arch
Wiki](https://wiki.archlinux.org/title/Trusted_Platform_Module#Accessing_PCR_registers).

You can look at the current values of these registers with this command:

```bash
systemd-analyze pcrs
```

For our purposes, we will choose these:

- **PCR0:** Hash of the UEFI firmware executable code (may change if you update
  UEFI)
- **PCR7:** Secure boot state - contains the certificates used to validate each
  boot application
- **PCR12:** Overridden kernel command line, credentials

> [!IMPORTANT]
> If you're using a boot loader (rather than booting directly from the Unified
> Kernel Images - EFI files), it is crucial that we choose all 3, including
> PCR12, as many tutorials only recommend 0 and 7, which would however lead to a
> security hole, where an attacker would be able to remove the drive with the
> (unencrypted) EFI partition, and modify the boot loader config. (With
> systemd-boot, this would be `loaders/loader.conf`).
>
> From there, the attacker could simply add a kernel argument like
> `init=/bin/bash`, or just enable editor support, allowing them to edit the
> parameters from the boot menu on the fly (The editor is actually enabled by
> default for systemd-boot). This would then bypass systemd as the init system
> and instead make the kernel run bash executable as the PID=1 (init) program.
> This would mean you would get directly into bash console that is running as
> root, without any need to enter a password.
>
> From that bash console, they could get the TPM to release the decryption
> password manually, as all of the selected PCRs do match.
>
> This wouldn't violate secure boot, as the `.efi` image files were unchanged,
> and are still signed, so the attacker would be able to boot into the system
> without issues.
>
> However, with PCR12, this is prevented, as it detects that the kernel cmdline
> arguments which were used, and if they don't match the recorded parameters
> during enrollment, TPM will not release the key.
>
> The nice thing about also selecting PCR12 is that it will actually allow us to
> securely keep systemd-boot editor support, which can be very useful for
> debugging, as all that will happen if we do edit the kernel command line will
> be that the TPM module will not release the credentials, and the initrd will
> just ask us to enter the password manually.

Optionally, you may also consider these:

- **PCR1:** Hash of the UEFI firmware data (changes when you change your BIOS settings)
- **PCR4:** Boot manager (changes when you change the boot manager)

> [!NOTE]
> You may be tempted to also add **PCR11**, which is a hash of the Unified
> Kernel Image, so that no other UKI can be booted, but this isn't necessary,
> as we're signing our UKIs, which means untrusted ones wouldn't pass secure
> boot, and if secure boot got disabled, PCR7 wouldn't pass.
>
> Additionally, enabling PCR11 would mean that you'd need to update the TPM
> every time your kernel/microcode/initrd/... is updated, as these will change
> the UKI file.

## Enroll a new key into TPM

The following command will enroll a new randomly generated key into the TPM
module and add it as a new keyslot of the specified LUKS2 encrypted device.

We also specify `--tpm2-pcrs=0+7+12`, which selects the PCR registers that we
decided on above.

```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7+12 /dev/gpt-auto-root-luks
```

<!-- markdownlint-disable MD028 -->

> [!NOTE]
> If you already have something in the tpm2 module, you'll want to add
> `--wipe-slot=tpm2` too.
>
> Note that wiping the slot will also remove the LUKS key slot that was added
> in the partition.

> [!TIP]
> If you're extra paranoid, you can also provide `--tpm2-with-pin=yes`, to
> prompt for a PIN code (passphrase) on each boot.
>
> I have mentioned why you may want to do this in the beginning.
>
> In case you do want to go with a PIN, you can also relatively safely drop
> PCR12, as you will be asked for credentials each time anyways, and at that
> point, the TPM unlocking is basically just as secure as regular passphrase
> unlocking, which systemd would fall back to if PCR12 wasn't met. But if you
> still wish to require a full encryption password if kernel params were
> changed, you can keep it (Personally, I like to still keep it).
>
> In case you followed the earlier command already before reading this, it's fine, just run:
>
> ```bash
> cryptsetup luksKillSlot /dev/gpt-auto-root-luks [slot number]
> ```
>
> Where the slot number should've been shown to you from the cryptenroll
> command. (If you only had one encryption password, that password will
> probably be in slot 0, so you'll want to use slot 1 here.)
>
> After that, you can re-run the `systemd-cryptenroll`, with the
> `--wipe-slot=tpm2` too.

<!-- markdownlint-enable MD028 -->

You will now be prompted for an existing LUKS password (needed to add a new LUKS
keyslot).

## Reboot

All that remains now is rebooting. The system should now get unlocked
automatically, without prompting for the password / prompting for the TPM PIN
instead of a decryption password.

If you're using a bootloader, I'd recommend also trying to modify the kernel
parameters, to make sure that TPM does not release the key anymore, and you will
be prompted to enter your full disk decryption key manually.

## Moving to a recovery key

Once you have confirmed that TPM unlocking is working, you can now optionally
get rid of your original LUKS key, in favor of a randomly generated recovery
key.

You might want to do this as this recovery key will be guaranteed to have high
entropy, likely making it a lot more secure than your original key, further
improving your chances, if someone attempts a brute-force decryption of your
drive.

> [!NOTE]
> I personally prefer to still use my own key which I have memorized, rather
> than a randomly generated one, as I trust it to have sufficiently high
> entropy and I do sometimes need to type it out manually when changing the
> kernel parameters, so I like to be able to do that without having to search
> for a recovery key somewhere. That said, if you store your recovery key
> properly, it will very likely be the technically more secure option.

To generate a recovery key, you can actually also just use `systemd-cryptenroll`
(though you can also do it manually with `cryptsetup`):

```bash
systemd-cryptenroll /dev/gpt-auto-root-luks --recovery-key
```

This will give you a randomized key, using characters that are easy to type. You
will even be given a QR code that can be scanned directly to save the password
on your phone.

Before proceeding with removing your own key, let's first make absolutely
certain that the recovery key you saved does in fact work. Without doing this,
you may get locked out!

```bash
cryptsetup luksOpen /dev/gpt-auto-root-luks crypttemp  # enter the recovery key
cryptsetup luksClose crypttemp
```

If this worked, proceed to:

```bash
cryptsetup luksRemoveKey /dev/gpt-auto-root-luks # Enter the original key to be deleted
```

## Removing the key from TPM

In case you'd ever want to remove the LUKS key from TPM, you can do so simply
with:

```bash
systemd-cryptenroll --wipe-slot=tpm2 /dev/gpt-auto-root-luks
```

This will actually also remove the LUKS key from the `/dev/gpt-auto-root-luks`
device as well as wiping it from the TPM2 chip.

## Sources / Attribution

- <https://nixos.wiki/wiki/TPM>
- <https://discourse.nixos.org/t/full-disk-encryption-tpm2/29454/6>
- <https://wiki.archlinux.org/title/systemd-cryptenroll>
- <https://wiki.archlinux.org/title/Trusted_Platform_Module#Accessing_PCR_registers>
- <https://pawitp.medium.com/full-disk-encryption-on-arch-linux-backed-by-tpm-2-0-c0892cab9704>
