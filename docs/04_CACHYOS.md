# CachyOS

CachyOS is an Arch-based Linux distribution with its own installers, package
repositories, kernels, and system configuration.

Personally, I prefer installing manually from the official Arch Linux ISO and
then extend this installation with CachyOS, because it gives me more control
over the packages and configuration I end up with. The CachyOS installer ISOs
are primarily aimed at setting up complete desktop.

This guide therefor walks you through how to add the CachyOS repositories and
components to an existing Arch Linux installation.

## Why

The reason behind why is simple: speed.

Official Arch Linux packages must support a very broad range of `x86-64`
processors, to make sure that even older CPUs can run these packages. But this
also means that they can't utilize some of the newer CPU instructions that
older CPUs don't support.

CachyOS offers multiple repos, which you can add to your pacman configuration
above the Arch Linux official ones, to have them take precedence. The repos
CachyOS maintained are focused on fairly new specific microarchitectures like
`x86-64-v3`, `x86-64-v4` and AMD `Zen 4` (or newer).

These packages can use instructions that are not part of the more generic
`x86-64` set baseline. CachyOS also selectively applies optimizations such as
`LTO`, `PGO`, and `BOLT` where the maintainers consider them beneficial.

The result is a performance improvement similar to what you might see with a
source-based distro like Gentoo, but without the hours of compiling that come
with that (of course, the CachyOS repos are still not tailored precisely to
your CPU, so Gentoo would still likely give you better results, but the
difference is usually very small).

The CachyOS repositories also contain customized and prebuilt packages that are
otherwise only available from the AUR or compiled locally. Some of these
packages include additional patches, backported fixes, or other
CachyOS-specific changes.

Some of these additional packages also include several custom Linux kernel
variants. These use custom configurations, compilation optimizations, and patch
sets intended for different workloads. Depending on the selected variant, these
can include alternative CPU schedulers, responsiveness and latency
improvements, filesystem and memory-management changes, additional hardware
support, and gaming-oriented patches.

## Installation

The installation process is fairly straight forward, as CachyOS provides a
script to automatically handle configuring pacman for you to work with the
CachyOS repos tailored for your active CPU. All you need to do is:

```bash
curl https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz && cd cachyos-repo
sudo ./cachyos-repo.sh
```

Source: <https://wiki.cachyos.org/features/optimized_repos/#adding-our-repositories-to-an-existing-arch-linux-install>

## Moving to an optimzied kernel

Most people decide to use CachyOS mainly to benefit from the optimized kernel
packages, as that is generally the most performance critical part of your
system. Even though the CachyOS repos also bring a bunch of other optimized
packages, which definitely contribute to performance improvements too,
switching the generic kernel for an optimized one is usually going to be the
most impactful.

```bash
sudo pacman -S linux-cachyos linux-cachyos-headers
```

You will then need to modify the mkinitcpio config to build out a UKI for this
kernel too:

```bash
# Comment `default_image` and uncomment `default_uki`
sudo nvim /etc/mkinitcpio.d/linux-cachyos.preset
```

Then build the preset with the UKI:

```bash
sudo mkinitcpio -p linux-cachyos
```

And sign the UKI for secure boot:

```bash
sbctl sign -s /efi/EFI/Linux/arch-linux-cachyos.efi
```

> [!NOTE]
> The `mkinitcpio` command might have already signed the image with `sbctl`
> automatically, but you will still want to run this, to add it to the database
> of files to be signed and verified by `sbctl`.

Then you can reboot.

## Automatic mirror ranking

For most Arch installation, `reflector` is used for handling optimizing the
mirror order (to improve pacman download speeds), however, for CachyOS, there
is a dedicated tool that includes the cachyos repos & mirrors which should be
used instead, being [cachyos-rate-mirrors]

```bash
sudo pacman -S cachyos-rate-mirrors
sudo systemctl enable --now cachyos-rate-mirrors.timer
sudo systemctl disable --now reflector.timer
```

[cachyos-rate-mirrors]: https://github.com/CachyOS/rate-mirrors

## Cachyos settings

Cachyos also provides a `cachyos-settings` package, which contains a set of
opinionated settings for various parts of the system. These are generally
designed primarily to improve performance. Personally, I like to handle these
on my own, allowing me to customize them a bit easier from within my dotfiles
repo, however, if you do wish to use them, you can simply do:

```bash
paru -S cachyos-settings
```
