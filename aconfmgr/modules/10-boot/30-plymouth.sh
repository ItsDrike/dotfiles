AddPackage plymouth # Graphical boot splash screen

# Show the Plymouth splash screen during boot.
printf '%s\n' 'splash' > "$(CreateFile /etc/cmdline.d/30-plymouth.conf)"
