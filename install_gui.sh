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
pushd "$(dirname "$0")" >/dev/null

# XDG base dir stuff
mkdir -p ~/.local/share/pki
ln -s ~/.local/share/pki ~/.pki
mkdir -p ~/.config/mozilla
ln -s ~/.config/mozilla ~/.mozilla
mkdir -p ~/.cache/nv
cp -ra home/.config/wget ~/.config
mkdir -p ~/.config/gtk-2.0
touch ~/.config/gtk-2.0/gtkrc
cp -ra home/.local/share/lein ~/.local/share

# DE configs (core apps/tools that make up the base graphical experience)
cp -ra home/.config/xdg-desktop-portal ~/.config
cp -ra home/.config/hypr ~/.config
cp -ra home/.config/swappy ~/.config
cp -ra home/.config/systemd ~/.config
#cp -ar home/.config/fontconfig ~/.config
cp -ra home/.config/swaync ~/.config

# Theme configs
cp -ar home/.config/qt5ct ~/.config
cp -ar home/.config/qt6ct ~/.config
cp -ar home/.config/Kvantum ~/.config
cp -arf home/.config/gtk-2.0 ~/.config
cp -ar home/.config/gtk-3.0 ~/.config
cp -ar home/.config/gtk-4.0 ~/.config
cp -ar home/.local/share/icons ~/.local/share
sudo cp root/etc/fonts/local.conf /etc/fonts

# Electron flags to make apps use wayland
cp home/.config/chromium-flags.conf ~/.config
cp home/.config/code-flags.conf ~/.config
cp home/.config/codium-flags.conf ~/.config
cp home/.config/electron-flags.conf ~/.config
cp home/.config/spotify-flags.conf ~/.config

# Specific application configs (fairly opinionated)
cp -ar home/.config/kitty ~/.config
cp -ar home/.config/pcmanfm ~/.config
cp -ar home/.config/pcmanfm-qt ~/.config
cp -ar home/.config/nomacs ~/.config
cp -ar home/.config/qimgv ~/.config
cp -ar home/.config/mpv ~/.config
cp -ar home/.config/pypoetry ~/.config
cp -ar home/.config/tmux ~/.config
cp -ar home/.config/hyfetch.json ~/.config

# Other configs
cp -ar home/.config/python_keyring ~/.config
cp home/.config/mimeapps.list ~/.config
cp home/.config/user-dirs.dirs ~/.config
cp home/.config/user-dirs.locale ~/.config

# Sync mirrors and update before other installations
paru -Syu --noconfirm

# WM Essentials
paru -S --noconfirm --needed \
  udisks2 udiskie gvfs gvfs-mtp gnome-keyring xorg-xinput polkit-gnome brightnessctl \
  xdg-user-dirs playerctl

# Wayland WM essentials
paru -S --noconfirm --needed \
  xdg-desktop-portal xdg-desktop-portal-gtk qt5-wayland qt6-wayland \
  wl-clipboard uwsm

# Wayland Utilities
paru -S --noconfirm --needed \
  wev wdisplays grim slurp swappy wf-recorder wlogout \
  hyprpicker hyprpaper hyprsunset

# Application launcher
paru -S --noconfirm --needed walker-bin elephant-bin elephant-archlinuxpkgs-bin \
  elephant-bluetooth-bin elephant-calc-bin elephant-clipboard-bin \
  elephant-desktopapplications-bin elephant-files-bin elephant-menus-bin \
  elephant-providerlist-bin elephant-runner-bin elephant-symbols-bin elephant-todo-bin \
  elephant-websearch-bin

# Hyprland
paru -S --noconfirm --needed hyprland xdg-desktop-portal-hyprland

# Audio
paru -S --noconfirm --needed \
  pipewire wireplumber pipewire-alsa pipewire-pulse pipewire-jack \
  alsa-utils alsa-firmware alsa-plugins rtkit pulsemixer wiremix

# Other Utilities
paru -S --noconfirm --needed \
  nm-connection-editor network-manager-applet ffmpegthumbnailer hyfetch fastfetch \
  tesseract tesseract-data-eng nvtop lazydocker lazygit

# Themes (Qt theme, GTK theme, icons theme, cursor theme)
paru -S --noconfirm --needed \
  papirus-folders-catppuccin-git tokyonight-gtk-theme-git \
  kvantum kvantum-qt5 qt5ct qt6ct kvantum-theme-catppuccin-git \
  rose-pine-cursor rose-pine-hyprcursor

# Fonts
paru -S --noconfirm --needed \
  gnu-free-fonts noto-fonts noto-fonts-emoji noto-fonts-cjk \
  otf-monaspace ttf-jost ttf-comic-neue ttf-material-design-icons-webfont \
  ttf-joypixels ttf-twemoji otf-openmoji ttf-ms-fonts

# Nerd Fonts (These contain most of the other fonts that I need)
paru -S --noconfirm --needed nerd-fonts

# Applications
paru -S --noconfirm --needed \
  vesktop firefox chromium kitty mpv pcmanfm-qt file-roller obs-studio qbittorrent \
  qalculate-gtk spotify qimgv nomacs stremio seahorse

# Bluetooth
paru -S --noconfirm --needed bluez bluez-utils blueberry blueman

# Lockscreen
# To test the lockscreen, you can run loginctl lock-session, while in a graphical session
paru -S --noconfirm --needed hyprlock hypridle systemd-lock-handler

# Temporary
# TODO: Swaync should be replaced by quickshell (also remove swaync.service)
# TODO: Eww should be replaced by quickshell (also remove associated services)
# TODO: Quickshell should be moved outside of temporary once config is ready
paru -S --noconfirm --needed quickshell swaync eww

# Dconf/Gsettings
paru -S --needed --noconfirm dconf
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme 'Tokyonight-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface font-name 'Noto Sans 10'
gsettings set org.gnome.desktop.interface document-font-name 'Noto Sans 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro 10'
gsettings set org.gnome.desktop.interface cursor-theme 'BreezeX-RosePine-Linux'
gsettings set org.gnome.desktop.interface cursor-size 24

# Services
sudo systemctl enable --now seatd.service
systemctl --user enable polkit-gnome-agent.service fumon.service hyprpaper.service hypridle.service hyprsunset.service elephant.service walker.service swaync.service systemd-lock-handler.service hyprlock.service swaync-inhibit-lock.service swaync-inhibit-unlock.service pcmanfm-qt.service nm-applet.service blueman-applet.service

echo "GUI Installation finished, you should now reboot and run uwsm start hyprland.desktop"
echo ""
echo "Optional extra steps:"
echo " - setup greetd (follow guide)"
echo " - setup printing (follow guide)"

popd >/dev/null
