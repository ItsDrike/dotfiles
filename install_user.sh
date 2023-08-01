#!/bin/bash
set -euo pipefail

# Arch installation script to be ran during OS installation, after user account creation.
# (Check install_root.sh first)
# $ arch-chroot /mnt zsh
# $ useradd itsdrike
# $ usermod -aG wheel itsdrike
# $ install -o itsdrike -g itsdrike -d /home/itsdrike
# $ passwd itsdrike
# $ chsh -s /usr/bin/zsh itsdrike
# $ su -l itsdrike
# $ git clone --recursive https://github.com/ItsDrike/dotfiles ~/dots
# $ cd ~/dots
# $ ./install_user.sh
# ---------------------------------------------------------------------------------------

if [ "$UID" = 0 ]; then
  echo >&2 "This script must be ran as an unpriviledged user (non-root)"
  exit 1
fi

# cd into the dotfiles dir, no matter where the script was called from
pushd "$(dirname "$0")"

# Install AUR helper (yay)
git clone https://aur.archlinux.org/yay.git ~/yay
pushd ~/yay
makepkg -si
popd
rm -rf ~/yay

# Install some useful packages
yay -S --noconfirm openssh cronie exa bat dust mlocate lshw trash-cli ncdu btop \
  dnsutils net-tools wget jq fzf polkit rebuild-detector hyperfine mediainfo git-delta \
  python-pip ripgrep zip unzip usbutils hexyl strace python-poetry pyenv yt-dlp \
  downgrade lf

# Copy over zsh configuration
cp -a home/.zshenv ~
mkdir -p ~/.config
cp -ra home/.config/shell ~/.config
cp -ra home/.config/zsh ~/.config
rm -rf ~/.config/zsh/.zgenom
git clone https://github.com/jandamm/zgenom ~/.config/zsh/.zgenom
install -m 700 -d ~/.local/share/gnupg

echo "You should now exit (logout) the user and relogin with: su -l itsdrike"
echo "This will put you into a configured ZSH shell, you can continue" \
  "configuring the rest of of the system manually from there"

popd
