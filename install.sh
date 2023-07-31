#!/bin/bash
set -euo pipefail

# Arch installation script to be ran after chroot
# -----------------------------------------------

if [ "$UID" != 0 ]; then
  echo >&2 "The script must be ran as root (after arch installation)!"
  exit 1
fi

# cd into the dotfiles dir, no matter where the script was called from
pushd "$(dirname "$0")"

# Install essential packages
pacman -Syu --noconfirm networkmanager neovim sudo reflector pacman-contrib man-db man-pages rsync btop bind tldr base-devel git

# Install packages necessary for this script / other scripts in this dotfiles repo
pacman -Syu --noconfirm python-rich bc lua jq bat

# Copy over system configuration data
cp root/etc/pacman.conf /etc
cp root/etc/hosts /etc
install -m 640 root/etc/sudoers /etc
install -m 640 root/etc/sudoers.d/* /etc/sudoers.d
cp root/etc/modprobe.d/nobeep.conf /etc/modprobe.d # disable motherboard speaker
cp root/etc/sysctl.d/* /etc/sysctl.d               # override some kernel parameters with more sensible values
cp -r root/etc/xdg/reflector /etc/xdg
cp -r root/usr/local/bin /usr/local
cp root/.rsync-filter /

# Sync pacman repos after /etc/pacman.conf got updated
sudo pacman -Sy

# Copy ZSH shell configuration
cp -a home/.zshenv ~
mkdir ~/.config
cp -ra home/.config/shell ~/.config
cp -ra home/.config/zsh ~/.config
rm ~/.config/shell/py-alias # we don't need pyenv python aliases for root
rm -rf ~/.config/zsh/.zgenom
git clone https://github.com/jandamm/zgenom ~/.config/zsh/.zgenom
install -m 700 -d ~/.local/share/gnupg

# Install zsh and make it the default shell for root
sudo pacman -S zsh
chsh -s /usr/bin/zsh root

# Enable some basic services
systemctl enable systemd-resolved
systemctl enable NetworkManager
systemctl enable paccache.timer
systemctl enable reflector.timer
systemctl enable pkgfile-update.timer

echo "You can exit the chroot and re-run it with: arch-chroot /mnt zsh"
echo "This will put you into a configured ZSH shell, you can continue" \
  "configuring the rest of the system manually from there"
