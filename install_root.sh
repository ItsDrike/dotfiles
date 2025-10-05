#!/bin/bash
set -euo pipefail

# Arch installation script to be ran during OS installation, after chroot.
# $ arch-chroot /mnt
# $ pacman -S git
# $ git clone https://github.com/ItsDrike/dotfiles ~/dots
# $ cd ~/dots
# $ ./install_root.sh
# $ exit
# $ ln -sf /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf
# -----------------------------------------------------------------------

if [ "$UID" != 0 ]; then
  echo >&2 "The script must be ran as root (after arch installation)!"
  exit 1
fi

# cd into the dotfiles dir, no matter where the script was called from
pushd "$(dirname "$0")" >/dev/null

# Sync mirrors and update before other installations
pacman -Syu --noconfirm

# Install essential packages
pacman -S --noconfirm --needed \
  networkmanager neovim sudo reflector pacman-contrib man-db man-pages rsync btop \
  bind base-devel git fd ripgrep fwupd arch-audit systemd-resolvconf opensmtpd ntp

# Install packages necessary for this script / other scripts in this dotfiles repo
pacman -S --noconfirm --needed python-rich bc lua jq bat

# Copy over system configuration data
cp root/etc/pacman.conf /etc
cp root/etc/hosts /etc
cp -r root/etc/smtpd /etc
HOSTNAME="$(cat /etc/hostname)"
sed -i "s/^127.0.1.1   pc.localdomain pc/127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}/g" /etc/hosts
install -m 640 root/etc/sudoers /etc
install -m 640 root/etc/sudoers.d/* /etc/sudoers.d
cp root/etc/modprobe.d/nobeep.conf /etc/modprobe.d # disable motherboard speaker
cp root/etc/sysctl.d/* /etc/sysctl.d               # override some kernel parameters with more sensible values
cp -r root/etc/xdg/reflector /etc/xdg
cp -r root/usr/local/bin /usr/local
cp root/.rsync-filter /

# Sync pacman repos after /etc/pacman.conf got updated
sudo pacman -Sy

# Enable some basic services
systemctl enable \
  systemd-resolved.service systemd-timesyncd.service systemd-oomd.service \
  paccache.timer pacman-filesdb-refresh.timer reflector.timer \
  NetworkManager.service smtpd.service
systemctl mask systemd-networkd.service # We have NetworkManager for this

# Install ZSH shell
pacman -S --noconfirm --needed zsh
cp -ra home/.config/shell ~/.config
rm -rf ~/.config/zsh/ || true # in case there is already some zsh config
cp -ra home/.config/zsh ~/.config
rm -rf ~/.config/zsh/.zgenom
git clone https://github.com/jandamm/zgenom ~/.config/zsh/.zgenom
chsh -s /usr/bin/zsh root

echo ""
echo "You can now run zsh or exit the chroot, and re-run it with: arch-chroot /mnt zsh."
echo "This will put you into a configured ZSH shell, you can continue " \
  "configuring the rest of the system manually from there."
echo ""
echo "Required extra steps:"
echo " - Symlink /etc/resolv.conf to use systemd-resolved stub (you need to be outside of arch-chroot for this, since arch-chroot is bind-mounting it). Run ln -sf /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf"
echo "Optional extra steps:"
echo " - enable cronie & copy /etc/crontab & anacrontab from dotfiles"
echo " - install docker and copy /etc/docker"
echo " - setup MAC address randomization by copying /etc/NetworkManager"
echo " - setup battery optimizations (follow guide)"
echo " - setup UKIs -> secure-boot -> systemd initramfs -> tpm unlocking (follow guides)"

popd >/dev/null
