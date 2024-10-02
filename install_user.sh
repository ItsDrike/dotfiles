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

if 0; then
  # Install AUR helper (paru)
  git clone https://aur.archlinux.org/paru.git ~/paru
  pushd ~/paru
  # Install rustup first, as otherwise, makepkg would ask whether to install rust or rustup
  # and we always want rustup, user shouldn't choose here
  sudo pacman -S rustup
  makepkg -si
  popd
  rm -rf ~/paru
fi

# Sync mirrors and update before other installations
paru -Syu --noconfirm

# Install some useful packages
paru -S --noconfirm --needed \
  openssh cronie exa bat dust mlocate lshw trash-cli ncdu btop \
  dnsutils net-tools wget jq fzf polkit rebuild-detector hyperfine mediainfo git-delta \
  python-pip ripgrep zip p7zip unzip usbutils hexyl strace python-poetry rye uv yt-dlp \
  luarocks cargo cmake meson npm downgrade lf glow xdg-ninja-git github-cli act lsof \
  procs du-dust skim thermald

# Make paru properly track git dependencies
paru --gendb

# Install some extensions for github-cli
gh auth login
gh extension install dlvhdr/gh-dash
gh extension install jrnxf/gh-eco
gh extension install meiji163/gh-notify

# Copy over zsh configuration
# Note that this assumes you've ran install_root.sh, whcih created /etc/zsh/zshenv
# with $ZOOTDIR exported. If you haven't done that, you'll want to symlink the
# ~/.config/zsh/.zshenv to your home directory.
mkdir -p ~/.config
cp -ra home/.config/shell ~/.config
rm -rf ~/.config/zsh/ || true # in case there is already some zsh config
cp -ra home/.config/zsh ~/.config
rm -rf ~/.config/zsh/.zgenom
git clone https://github.com/jandamm/zgenom ~/.config/zsh/.zgenom
mkdir -p ~/.cache/zsh
touch ~/.cache/zsh/history

# Copy other user configurations
mkdir -p ~/.local
cp -ra home/.local/bin ~/.local
cp -ra home/.config/python ~/.config
install -m 700 -d ~/.local/share/gnupg
mkdir -p ~/.local/share/npm/lib
mkdir -p ~/.local/state
cp -ra home/.config/btop ~/.config
mkdir -p ~/.config/gtk-2.0
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/java

# More opinionated settings, you may not need some of these
cp home/.config/black ~/.config
cp -ra home/.config/git ~/.config/git
cp -ra home/.config/gtk-2.0 ~/.config
cp -ra home/.config/gtk-3.0 ~/.config
cp -ra home/.config/lf ~/.config
cp -ra home/.config/npm ~/.config
cp home/.config/pythonrc.py ~/.config
cp -ra home/.local/share/gnupg/gpg.conf ~/.local/share/gnupg
chmod 600 ~/.local/share/gnupg/gpg.conf
mkdir ~/.config/wakatime
cp home/.config/user-dirs.dirs ~/.config
cp home/.config/user-dirs.locale ~/.config
cp -ra home/.config/tealdeer ~/.config

# Source the environment file to make sure the commands below
# install to the correct (XDG) location.
export ZSH_VERSION=0 # necessary for the environment script to succeed
# shellcheck source=home/.config/shell/environment
source ~/.config/shell/environment

# Install stable channel default rust toolchain
rustup default stable

# Install various python versions with rye
rye toolchain list --include-downloadable | rg "cpython@3.12" | cut -d' ' -f1 | head -n 1 | xargs rye toolchain fetch
rye toolchain list --include-downloadable | rg "cpython@3.11" | cut -d' ' -f1 | head -n 1 | xargs rye toolchain fetch
rye toolchain list --include-downloadable | rg "cpython@3.10" | cut -d' ' -f1 | head -n 1 | xargs rye toolchain fetch
rye toolchain list --include-downloadable | rg "cpython@3.9" | cut -d' ' -f1 | head -n 1 | xargs rye toolchain fetch
rye toolchain list --include-downloadable | rg "cpython@3.8" | cut -d' ' -f1 | head -n 1 | xargs rye toolchain fetch
rye toolchain list --include-downloadable | rg "cpython@3.7" | cut -d' ' -f1 | head -n 1 | xargs rye toolchain fetch
rye toolchain list --include-downloadable | rg "cpython@3.6" | cut -d' ' -f1 | head -n 1 | xargs rye toolchain fetch

# Install ipython with rye
rye tools install ipython
rye tools install ruff
rye tools install basedpyright
rye tools install pyright
rye tools install mypy

# Pull my public key and give it ultimate trust
# (Obviously, you might not want to do this in your case,
# you can give it a lower trust level, or not import it at all)
gpg --keyserver keys.openpgp.org --recv-keys FA2745890B7048C0
echo "136F5E08AFF7F6DD3E9227A0FA2745890B7048C0:6:" | gpg --import-ownertrust

# Enable systemd services
sudo systemctl enable --now thermald

echo "You should now exit (logout) the user and relogin with: su -l itsdrike"
echo "This will put you into a configured ZSH shell, you can continue" \
  "configuring the rest of of the system manually from there"

popd
