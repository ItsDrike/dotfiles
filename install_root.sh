#!/bin/bash
set -euo pipefail

# Arch installation script to be ran during OS installation, after chroot.
# $ arch-chroot /mnt
# $ pacman -S git
# $ git clone https://github.com/ItsDrike/dotfiles ~/dots
# $ cd ~/dots
# $ ./install_root.sh
# -----------------------------------------------------------------------

if [ "$UID" != 0 ]; then
  echo >&2 "The script must be ran as root (after arch installation)!"
  exit 1
fi

# cd into the dotfiles dir, no matter where the script was called from
pushd "$(dirname "$0")"

# Sync mirrors and update before other installations
pacman -Syu --noconfirm

# Install essential packages
pacman -S --noconfirm --needed \
  networkmanager neovim sudo reflector pacman-contrib man-db man-pages rsync btop bind tldr base-devel git pkgfile

# Install packages necessary for this script / other scripts in this dotfiles repo
pacman -S --noconfirm --needed python-rich bc lua jq bat

# Copy over system configuration data
cp root/etc/pacman.conf /etc
cp root/etc/hosts /etc
HOSTNAME="$(cat /etc/hostname)"
sed -i "s/^127.0.1.1   pc.localdomain pc/127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}/g" /etc/locale.gen
install -m 640 root/etc/sudoers /etc
install -m 640 root/etc/sudoers.d/* /etc/sudoers.d
cp root/etc/modprobe.d/nobeep.conf /etc/modprobe.d # disable motherboard speaker
cp root/etc/sysctl.d/* /etc/sysctl.d               # override some kernel parameters with more sensible values
cp -r root/etc/xdg/reflector /etc/xdg
cp -r root/usr/local/bin /usr/local
cp root/.rsync-filter /

# Sync pacman repos after /etc/pacman.conf got updated
sudo pacman -Sy

# Install zsh and make it the default shell for root
sudo pacman -S --noconfirm --needed zsh
chsh -s /usr/bin/zsh root

# Copy ZSH shell configuration
mkdir -p /etc/zsh
cp -ra root/etc/zsh /etc
mkdir -p ~/.config
cp -ra home/.config/shell ~/.config
cp -ra home/.config/zsh ~/.config
rm ~/.config/shell/py-alias # we don't need pyenv python aliases for root
rm -rf ~/.config/zsh/.zgenom
git clone https://github.com/jandamm/zgenom ~/.config/zsh/.zgenom
install -m 700 -d ~/.local/share/gnupg

# Enable some basic services
systemctl enable systemd-resolved
systemctl enable systemd-timesyncd
systemctl enable NetworkManager
systemctl mask systemd-networkd # We have NetworkManager for this
systemctl enable paccache.timer
systemctl enable reflector.timer
systemctl enable pkgfile-update.timer

echo "You can exit the chroot and re-run it with: arch-chroot /mnt zsh"
echo "This will put you into a configured ZSH shell, you can continue" \
  "configuring the rest of the system manually from there"

popd
