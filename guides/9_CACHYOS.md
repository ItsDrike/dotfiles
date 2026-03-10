# CachyOS

This guide will walk you through converting your existing Arch Linux installation into a CachyOS installation / installation using the CachyOS optimzied repos.

## Why

TODO

## Installation

The installation process is fairly straight forward, as CachyOS provides a script to automatically handle configuring
pacman for you to work with the CachyOS repos. All you need to do is:

```bash
curl https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz && cd cachyos-repo
sudo ./cachyos-repo.sh
```

Source: <https://wiki.cachyos.org/features/optimized_repos/#adding-our-repositories-to-an-existing-arch-linux-install>

## Moving to an optimzied kernel

Most people decide to use CachyOS mainly to benefit from the optimized kernel packages, as that is generally the most
performance critical part of your system. Even though the CachyOS repos also bring a bunch of other optimized packages,
which definitely contribute to performance improvements too, switching the generic kernel for an optimized one is
usually going to be the most impactful.

TODO

## Automatic mirror ranking

For most Arch installation, `reflector` is used for handling optimizing the mirror order (to improve pacman download speeds), however, for CachyOS, there is a dedicated tool that includes the cachyos repos & mirrors which should be used instead, being [cachyos-rate-mirrors]

```bash
paru -S cachyos-rate-mirrors
sudo systemctl enable --now cachyos-rate-mirrors.timer
sudo systemctl disable --now reflector.timer
```

[cachyos-rate-mirrors]: https://github.com/CachyOS/rate-mirrors

## Cachyos settings

Cachyos also provides a `cachyos-settings` package, which contains a set of opinionated settings for various parts of
the system. These are generally designed primarily to improve performance. Personally, I like to handle these on my
own, allowing me to customize them a bit easier from within my dotfiles repo, however, if you do wish to use them, you
can simply do:

```bash
paru -S cachyos-settings
```
