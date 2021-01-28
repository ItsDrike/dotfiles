#!/bin/sh
set -e
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

echo "Setting up Noto Emoji font..."
# Install  noto-fonts-emoji repository as the basic emoji font
pacman -S noto-fonts-emoji --needed
# Install powerline-fonts for powerline statusline
pacman -S powerline-fonts --needed
echo "Font packages installed, setting up font-config"
# Make sure noto emojis are preferred font /etc/fonts/local.conf
# another way to do this would be to manually figure out the number and use /etc/fonts/conf.d/01-notosans.conf
# note that the `01` might be too agressive and override other fonts, it is therefore easier to just use `local.conf`
# if you still want to use the manual numbered representation, make sure to store the file into /etc/fonts/conf.avail/XX-notosans.conf
# from which you will then make a symlink pointing to /etc/fonts/conf.d (same name)
echo '<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
 <alias>
   <family>sans-serif</family>
   <prefer>
     <family>Noto Sans</family>
     <family>Noto Color Emoji</family>
     <family>Noto Emoji</family>
     <family>DejaVu Sans</family>
   </prefer>
 </alias>

 <alias>
   <family>serif</family>
   <prefer>
     <family>Noto Serif</family>
     <family>Noto Color Emoji</family>
     <family>Noto Emoji</family>
     <family>DejaVu Serif</family>
   </prefer>
 </alias>

 <alias>
  <family>monospace</family>
  <prefer>
    <family>Noto Mono</family>
    <family>Noto Color Emoji</family>
    <family>Noto Emoji</family>
    <family>DejaVu Sans Mono</family>
   </prefer>
 </alias>
</fontconfig>

' > /etc/fonts/local.conf
# Update font cache
fc-cache -f
echo "Noto Emoji Font installed! You will need to restart application to see changes."

