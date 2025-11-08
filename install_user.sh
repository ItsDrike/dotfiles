#!/bin/bash
set -euo pipefail

# Arch installation script to be ran during OS installation, after user account creation.
# (Check install_root.sh first)
# $ arch-chroot /mnt zsh
# $ useradd itsdrike
# $ usermod -aG wheel itsdrike
# $ install -o itsdrike -g itsdrike -d /home/itsdrike
# $ mv ~/dots /home/itsdrike
# $ chown -R itsdrike:itsdrike /home/itsdrike/dots
# $ passwd itsdrike
# $ su -l itsdrike
# $ cd ~/dots
# $ ./install_user.sh
# ---------------------------------------------------------------------------------------

if [ "$UID" = 0 ]; then
  echo >&2 "This script must be ran as an unpriviledged user (non-root)"
  exit 1
fi

# cd into the dotfiles dir, no matter where the script was called from
pushd "$(dirname "$0")" >/dev/null

# Source the environment file to make sure the commands below
# install to the correct (XDG) locations.
source home/.config/shell/environment

# Sync mirrors and update all packages first
sudo pacman -Syu --noconfirm

# Make sure we have rustup installed and with the stable channel rust toolchain. This is required for
# installing paru later on (and any other rust dependencies), to prevent a prompt asking whether we
# want rust or rustup package and with rustup to also prevent the no default channel configured.
sudo pacman -S --needed --noconfirm rustup
rustup default stable

if ! command -v paru >/dev/null; then
  # Install AUR helper (paru)
  git clone https://aur.archlinux.org/paru.git ~/paru
  pushd ~/paru
  makepkg -si
  popd
  rm -rf ~/paru
fi

# Sync mirrors and update with paru before other installations
paru -Syu --noconfirm

# Install some useful packages
paru -S --noconfirm --needed \
  openssh cronie exa bat dust mlocate lshw trash-cli ncdu btop \
  dnsutils net-tools wget jq fzf polkit rebuild-detector hyperfine mediainfo git-delta \
  python-pip ripgrep zip p7zip unzip unrar usbutils hexyl strace uv yt-dlp luarocks cargo \
  cmake meson npm downgrade glow xdg-ninja-git github-cli act lsof procs skim thermald \
  tealdeer pkgfile zoxide openbsd-netcat

# Make paru properly track git dependencies
paru --gendb

## Install some extensions for github-cli
## This is currently disabled as doing the login here is very annoying
## (requires manually typing out the github auth token, since we don't have a browser)
#gh auth login
#gh extension install dlvhdr/gh-dash
#gh extension install jrnxf/gh-eco

# Create some basic dirs
mkdir -p ~/.config
mkdir -p ~/.local/{share,state,bin}

# Copy over zsh & starship configuration
#
# Note that this assumes you've ran install_root.sh, which created /etc/zsh/zshenv
# with $ZOOTDIR exported. If you haven't done that, you'll want to copy it over from
# my dotfiles. If you can't (don't have root rights), it's also possible to use ~/.zshenv,
# which you can symlink to ~/.config/zsh/.zshenv.
pacman -S --noconfirm --needed zsh starship
cp -ra home/.config/shell ~/.config
rm -rf ~/.config/zsh/ || true # in case there is already some zsh config
cp -ra home/.config/zsh ~/.config
rm -rf ~/.config/zsh/.zgenom
git clone https://github.com/jandamm/zgenom ~/.config/zsh/.zgenom
mkdir -p ~/.cache/zsh
touch ~/.cache/zsh/history
cp home/.config/starship.toml ~/.config
chsh -s /usr/bin/zsh "$USER"

# GnuPG
install -m 700 -d ~/.local/share/gnupg
cp -ra home/.local/share/gnupg/gpg.conf ~/.local/share/gnupg
chmod 600 ~/.local/share/gnupg/gpg.conf

# Copy other user configurations
mkdir -p ~/.config/java
mkdir -p ~/.local/share/npm/lib
cp -ra home/.local/bin ~/.local
cp -ra home/.config/python ~/.config
cp -ra home/.config/btop ~/.config
cp -ra home/.config/git ~/.config
cp -ra home/.config/gh ~/.config
cp -ra home/.config/npm ~/.config
cp -ra home/.config/tealdeer ~/.config

# Install various python versions with uv
uv python install 3.13 3.12 3.11 3.10 3.9 3.8

# Install various useful python packages
paru -S --noconfirm --needed ipython ruff pyright mypy basedpyright

# Pull my public key and give it ultimate trust
# (Obviously, you might not want to do this in your case,
# you can give it a lower trust level, or not import it at all)
gpg --keyserver keys.openpgp.org --recv-keys FA2745890B7048C0
echo "136F5E08AFF7F6DD3E9227A0FA2745890B7048C0:6:" | gpg --import-ownertrust

# Enable systemd services
sudo systemctl enable thermald pkgfile-update.timer

echo "You should now exit (logout) the user and relogin with: su -l itsdrike"
echo "This will put you into a configured ZSH shell, you can continue" \
  "configuring the rest of of the system manually from there"
echo ""
echo "Optional extra steps:"
echo "- import gpg private keys"
echo "- import ssh config"
echo "- import git credentials"

popd >/dev/null
