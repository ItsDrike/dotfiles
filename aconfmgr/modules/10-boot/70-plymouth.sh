AddPackage plymouth # Graphical boot splash screen

# Generated boot-time measurement.
IgnorePath '/var/lib/plymouth/boot-duration'

# Show the Plymouth splash screen during boot.
printf '%s\n' 'splash' > "$(CreateFile /etc/cmdline.d/30-plymouth.conf)"
