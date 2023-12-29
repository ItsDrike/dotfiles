#!/bin/bash
set -euo pipefail

# Arch installation script to be ran for an unpriviledged user after base setup.
# (Check install_user.sh first)
# $ cd ~/dots
# $ ./install_gui.sh
# ------------------------------------------------------------------------------

if [ "$UID" = 0 ]; then
  echo >&2 "This script must be ran as an unpriviledged user (non-root)"
  exit 1
fi

# cd into the dotfiles dir, no matter where the script was called from
pushd "$(dirname "$0")"

# Copy over various settings
cp -a home/.pki ~ # symlink
mkdir -p ~/.local/share/pki
cp -a home/.mozilla ~ # symlink
mkdir -p ~/.config/mozilla
mkdir -p ~/.config/nv
cp -ar home/.local/share/thumbnailers ~/.local/share
cp -ar home/.local/share/icons ~/.local/
cp -ar home/.config/fontconfig ~/.config
cp -ar home/.config/python_keyring ~/.config
cp -ra home/.config/wget ~/.config

# More opinionated settings
cp home/.config/mimeapps.list ~/.config
cp -ar home/.config/mpv ~/.config
cp -ar home/.config/pcmanfm ~/.config
cp -ar home/.config/pcmanfm-qt ~/.config
cp -ar home/.config/pypoetry ~/.config
cp -ar home/.config/qt5ct ~/.config
cp -ar home/.config/tmux ~/.config
cp -ra home/.config/wireplumber ~/.config
cp -ra home/.config/alacritty ~/.config
cp -ra home/.config/kitty ~/.config
cp -ra home/.config/systemd ~/.config
cp -ra home/.config/dunst ~/.config
cp -ra home/.config/eww ~/.config

# Wayland-specific settings
cp home/.config/chromium-flags.conf ~/.config
cp -ra home/.config/swappy ~/.config
cp -ra home/.config/swayidle ~/.config
cp -ra home/.config/swaylock ~/.config
cp -ra home/.config/wofi ~/.config

# Sync mirrors and update before other installations
yay -Syu --noconfirm

# Instal fonts
yay -S --noconfirm --needed \
  libxft ttf-hack ttf-joypixels noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-font-awesome \
  ttf-jetbrains-mono xorg-font-util ttf-ms-fonts otf-jost ttf-material-design-icons-git \
  nerd-fonts-git

# Audio
yay -S --noconfirm --needed \
  pipewire pipewire-pulse pipewire-pulse pipewire-jack wireplumber alsa-utils pulsemixer

# Themes
yay -S --noconfirm --needed \
  gnome-themes-extra gnome-icon-theme-extras python-qt-material notify-osd papirus-icon-theme \
  lxappearance adwaita-qt5 adwaita-qt6 qt5ct

# WM Essentials
yay -S --noconfirm --needed \
  dunst udisks2 udiskie gvfs gnome-keyring xorg-xinput polkit-gnome

# Wayland WM essentials
yay -S --noconfirm --needed \
  wl-clipboard xdg-desktop-portal qt5-qayland qt6-wayland wev wl-gammarelay-rs wdisplays

# Utilities
yay -S --noconfirm --needed \
  nm-connection-editor ffmpegthumbnailer upower devour

# Wayland Utilities
yay -S --noconfirm --needed \
  grim slurp wofi swappy-git swayidle swaybg wf-recorder wlogout hyprpicker-git clipman

# Applications
yay -S --noconfirm --needed \
  discord firefox chromium kitty mpv pcmanfm-qt file-roller obs-studio qbittorrent \
  qalculate-gtk-nognome spotify nomacs
echo "y" | sudo pacman -S --ask 4 --noconfirm --needed nodejs-lts-gallium # ask for package overwrite (potentially conflicting with base 'nodejs' dep) and overwrite it (for stremio)
yay -S --noconfirm --needed stremio

# Bluetooth
yay -S --noconfirm --needed bluez bluiz-utils blueberry

# Build hyprland
yay -S --noconfirm --needed \
  gdb ninja gcc cmake meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite \
  xorg-xinput libxrender pixman wayland-protocols cairo pango seatd libxkbcommon xcb-util-wm xorg-xwayland \
  libinput libliftoff libdisplay-info cpio
mkdir -p ~/.local/src
git clone --recursive https://github.com/hyprwm/Hyprland ~/.local/src/Hyprland || true # don't fail if exists
pushd ~/.local/src/Hyprland
# TODO: Consider git pull here, in case the clone fell through and hyprland was already installed
git checkout "$(git rev-list --tags --max-count=1)" # check out the last tag (latest stable release)
make all
sudo make install
popd
yay -S --noconfirm --needed xdg-desktop-portal-hyprland-git hyprpaper
sudo pacman -R --noconfirm xdg-desktop-portal-gnome || true # don't fail if this isn't installed
cp -ra home/.config/hypr ~/.config/hypr                     # loads dwindle-autogoroup

# Hyprland dwindle-autogroup plugin
git clone --recursive https://github.com/ItsDrike/hyprland-dwindle-autogroup ~/.local/src/hyprland-dwindle-autogroup || true # don't fail if exists
pushd ~/.local/src/hyprland-dwindle-autogroup
make install
popd

# Build eww
sudo pacman -S --noconfirm --needed \
  gtk3 gtk-layer-shell rustup openbsd-netcat pango gdk-pixbuf2 cairo glib2 gcc-libs glibc libdbusmenu-gtk3
sudo rustup default stable
# Use a fork instead of the original elkowar/eww, for system tray suppot
sudo mkdir -p /usr/local/src
sudo git clone https://github.com/ralismark/eww /usr/local/src/eww || true # don't fail if exists
pushd /usr/local/src/eww
sudo git checkout tray-3
sudo cargo build --release --no-default-features --features=wayland
sudo ln -s /usr/local/src/eww/target/release/eww /usr/local/bin
popd

# Lockscreen
yay -S --noconfirm --needed swaylock-effects-git systemd-lock-handler
systemctl --user enable systemd-lock-handler.service
# You'll need the systemd-lock-handler-swaylock.service from my dotfiles (in home/.config/systemd/user)
# this is copied above by default, but if you're editing the script, be aware of it
systemctl enable --user systemd-lock-handler-swaylock.service
# To test the lockscreen, you can run loginctl lock-session, while in a graphical session

# Generate db for -git packages
yay -Y --gendb

popd
