# Hibernation

Hibernation, also called **S4** sleeping or Suspend to disk, is the process of saving the machine's state into swap
space, and completely powering off the machine. This means that there will be no power consumption until the next
power on.

This can be an extremely nice feature to have on laptops, allowing you to save the state at any point without
worrying of running out of battery (like you might with regular Suspend / **S3** sleeping, which keeps the RAM
powered on).

To be able to hibernate, you will need to have a swap partition or file (although using a swap file could be
problematic if you use encryption, so a swap partition is recommended), which should ideally be as big as your RAM
(though even if your swsp is smaller than RAM, you still have a good chance of hibernating successfully).

## Initramfs

First thing we'll need to do is set up initramfs with support to restore the previous state after hibernation.

- When using a busybox-based initramfs (with `udev` in your `HOOKS`), you will need to add a `resume` hook anywhere
  after `udev`.
- With `systemd` based initramfs (you have `systemd` in your `HOOKS`), a resume mechanism is already provided, no
  need to add any extra hooks.

## Kernel parameters

To be able to resume from hibernation, you will need to let the kernel know where to resume from, that is, your swap
partition. You can do that with the `resume` parameter, like this:

- `resume=UUID=...`
- `resume="PARTLABEL=Swap partition`
- `resume=/dev/archVolumeGroup/archLogicalVolume`

> [!NOTE]
> If you're using `systemd` based initramfs, you don't actually need this kernel parameter, as it can pick up the
> dynamically mounted swap partition and check it's contents for the hibernation data. If found, systemd will
> perform a hibernation resume.
>
> This is especially nice for certain more complex setups, such as a swap file on an encrypted partition.

### Swap File

If you'd like to use a swap file, set `resume` parameter to the partition on which your swap file lives, and set
`resume_offset`, which you can find with `filefrag -v /path/to/swapfile` command. (When on btrfs, the `filefrag`
command will not work, instead you should use `btrfs inspect-internal map-swapfile -r /path/to/swapfile`)
