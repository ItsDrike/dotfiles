# Auto-mounting other encrypted partitions

If you've set up multiple encrypted partitions (a common reason to do so is
having multiple drives), you will likely want to have these other partitions
mounted automatically after the root partition, during the boot process.

> [!TIP]
> You can safely skip this guide if you only have a single encrypted partition
> (with the root).

## /etc/crypttab

Obviously, with encrypted partitions, you can't simply specify the mounting
instructions into your `/etc/fstab`, instead, there is a special file designed
precisely for this purpose: `/etc/crypttab`. Just like with `fstab`, systemd
will read `crypttab` during boot and attempt to mount the entries inside of it.

From here, you can add entries for mounting your encrypted partitions, like so:

```txt
# Configuration for encrypted block devices.
# See crypttab(5) for details.

# NOTE: Do not list your root (/) partition here, it must be set up
#       beforehand by the initramfs (/etc/mkinitcpio.conf).

# <name>         <device>             <password>       <options>
cryptdata        LABEL=DATA           none             discard
```

> [!NOTE]
> The `discard` option is specified to enable TRIM on SSDs, which should improve
> their lifespan. It is not necessary if you're using an HDD.

The `<name>` option specifies the name of the decrypted mapper device, so in
this case, the decrypted device would be in `/dev/mapper/cryptdata`. We can then
add mounting instructions into `/etc/fstab`, that work with this mapper device.

Specifying a partition in here will result in you being prompted for a
decryption password each time during boot. If you only have one encrypted
partition like this, and your root partition isn't encrypted, this will be
sufficient for you.

## Key files

That said, if you have multiple encrypted partitions, or your root partition is
encrypted too, you might find it pretty annoying to have to enter a password for
each of your encrypted partitions every time.

For this reason, crypttab includes the `<password>` option, which we originally
left as `none`. We can use this field to specify a path to a "key file". This is
basically just a file that holds the encryption password.

> [!IMPORTANT]
> Storing the decryption password in a key file like this can only be done
> safely if that key file is stored on another encrypted partition, which we
> decrypted in another way (usually by being prompted for the password).
>
> In this example, we'll be storing the key files in `/etc/secrets`, which is
> safe as our root partition is encrypted.

LUKS encryption has support for having multiple keys for the same parition.
We'll utilize this support and add 2nd key slot to all of the partitions that we
wish to auto-mount.

```bash
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

Finally, we'll modify the `/etc/crypttab` record and add our new keyfile as the
password for this partition:

```txt
# Configuration for encrypted block devices.
# See crypttab(5) for details.

# NOTE: Do not list your root (/) partition here, it must be set up
#       beforehand by the initramfs (/etc/mkinitcpio.conf).

# <name>         <device>       <password>                       <options>
cryptdata        LABEL=DATA     /etc/secrets/keyFile-data.bin    discard
```

### /etc/fstab

While the crypttab file opens the encrypted block devices and creates the mapper
interfaces for them, to mount those to a concrete directory, we still use
/etc/fstab. Below is the /etc/fstab that I use on my system:

<!-- markdownlint-disable MD010 MD013 -->

```text
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

# /dev/mapper/cryptfs LABEL=ARCH UUID=bffc7a62-0c7e-4aa9-b10e-fd68bac477e0
/dev/mapper/cryptfs	/         	btrfs     	rw,noatime,compress=zstd:1,ssd,space_cache=v2,subvol=/@         	0 1
/dev/mapper/cryptfs	/home     	btrfs     	rw,noatime,compress=zstd:1,ssd,space_cache=v2,subvol=/@home     	0 1
/dev/mapper/cryptfs	/var/log  	btrfs     	rw,noatime,compress=zstd:2,ssd,space_cache=v2,subvol=/@log      	0 1
/dev/mapper/cryptfs	/var/cache	btrfs     	rw,noatime,compress=zstd:3,ssd,space_cache=v2,subvol=/@cache    	0 1
/dev/mapper/cryptfs	/tmp      	btrfs     	rw,noatime,compress=no,ssd,space_cache=v2,subvol=/@tmp          	0 1
/dev/mapper/cryptfs	/data     	btrfs     	rw,noatime,compress=zstd:5,ssd,space_cache=v2,subvol=/@data     	0 2
/dev/mapper/cryptfs	/.btrfs   	btrfs     	rw,noatime,ssd,space_cache=v2                                   	0 2 # btrfs root

# endregion
# region: Bind mounts

# Write kernel images to /efi/arch, not directly to efi system partition (esp), to avoid conflicts when dual booting
/efi/arch-1 	    /boot     	none      	rw,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro,bind 	0 0

# endregion
```

<!-- markdownlint-enable MD010 MD013 -->
