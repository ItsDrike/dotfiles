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
mkdir -p ~/.cache/nv
touch ~/.cache/nv/.keep
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
cp -ar home/.config/qt6ct ~/.config
cp -ar home/.config/Kvantum ~/.config
cp -ar home/.config/gtk-2.0 ~/.config
cp -ar home/.config/gtk-3.0 ~/.config
cp -ar home/.config/gtk-4.0 ~/.config
cp -ar home/.config/tmux ~/.config
cp -ra home/.config/hyfetch ~/.config
cp -ra home/.config/wireplumber ~/.config
cp -ra home/.config/alacritty ~/.config
cp -ra home/.config/kitty ~/.config
cp -ra home/.config/systemd ~/.config
cp -ra home/.config/dunst ~/.config
cp -ra home/.config/eww ~/.config
cp -ra home/.config/hypr ~/.config
cp home/.config/chromium-flags.conf ~/.config
cp -ra home/.config/swappy ~/.config
cp -ra home/.config/wofi ~/.config
cp -ra home/.config/nomacs ~/.config
cp -ra home/.config/qimgv ~/.config
cp -ra home/.config/xdg-desktop-portal ~/.config

# Sync mirrors and update before other installations
paru -Syu --noconfirm

# Instal fonts
paru -S --needed \
  libxft xorg-font-util \
  ttf-joypixels otf-jost lexend-fonts-git ttf-sarasa-gothic \
  ttf-roboto ttf-work-sans ttf-comic-neue \
  gnu-free-fonts tex-gyre-fonts ttf-liberation otf-unifont \
  inter-font ttf-lato ttf-dejavu noto-fonts noto-fonts-cjk \
  noto-fonts-emoji ttf-material-design-icons-git \
  ttf-font-awesome ttf-twemoji otf-openmoji \
  adobe-source-code-pro-fonts adobe-source-han-mono-otc-fonts \
  adobe-source-sans-fonts ttf-jetbrains-mono otf-monaspace \
  ttf-ms-fonts
# nerd fonts (I like to install specific pkgs instead of the whole nerd-fonts group
# as it's pretty large: ~8GB)
paru -S --needed \
  ttf-firacode-nerd otf-firamono-nerd ttf-iosevka-nerd ttf-nerd-fonts-symbols \
  ttf-hack-nerd ttf-heavydata-nerd ttf-gohu-nerd

# Audio
paru -S --noconfirm --needed \
  pipewire pipewire-pulse pipewire-pulse pipewire-jack wireplumber alsa-utils pulsemixer

# Themes
paru -S --noconfirm --needed \
  rose-pine-cursor papirus-folders-catppuccin-git tokyonight-gtk-theme-git \
  nwg-look kvantum kvantum-qt5 qt5ct qt6ct kvantum-theme-catppuccin-git

# Extra themes (I don't use these in my config, but I might switch at some point
# and it's nice to have them listed and available)
paru -S --noconfirm --needed \
  gnome-themes-extra gnome-icon-theme-extras python-qt-material notify-osd papirus-icon-theme \
  adwaita-qt5 adwaita-qt6

# WM Essentials
paru -S --noconfirm --needed \
  dunst udisks2 udiskie gvfs gvfs-mtp gnome-keyring xorg-xinput polkit-gnome brightnessctl

# Wayland WM essentials
paru -S --noconfirm --needed \
  wl-clipboard xdg-desktop-portal qt5-wayland qt6-wayland wev wl-gammarelay-rs wdisplays

# Utilities
paru -S --noconfirm --needed \
  nm-connection-editor ffmpegthumbnailer upower devour hyfetch fastfetch bottom tesseract tesseract-data-eng

# Wayland Utilities
paru -S --noconfirm --needed \
  grim slurp wofi swappy-git wf-recorder wlogout clipman hyprpicker hyprpaper

# Applications
paru -S --noconfirm --needed \
  vesktop firefox chromium kitty mpv pcmanfm-qt file-roller obs-studio qbittorrent \
  qalculate-gtk spotify qimgv nomacs stremio seahorse

# Bluetooth
paru -S --noconfirm --needed bluez bluez-utils blueberry

# Hyprcursor theme of my choice
mkdir -p ~/.local/share/icons
pushd ~/.local/share/icons
git clone https://github.com/ndom91/rose-pine-cursor-hyprcursor
popd

# Lockscreen
# To test the lockscreen, you can run loginctl lock-session, while in a graphical session
paru -S --noconfirm --needed hyprlock hypridle systemd-lock-handler

# Eww bar
paru -S --noconfirm --needed eww

# Hyprland
paru -S --noconfirm --needed hyprland xdg-desktop-portal-hyprland
sudo pacman -R --noconfirm xdg-desktop-portal-gnome || true # don't fail if this isn't installed

# Tools needed to build hyprland from source
# (even though I will not be building hyprland here and will instead use the packaged version,
# I like to have these on my system, since I sometimes want to experiment with building hyprland
# for debuggin)
paru -S --noconfirm --needed \
  gdb ninja gcc cmake meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite \
  xorg-xinput libxrender pixman wayland-protocols cairo pango seatd libxkbcommon xcb-util-wm xorg-xwayland \
  libinput libliftoff libdisplay-info cpio hyprlang hyprcursor

popd
