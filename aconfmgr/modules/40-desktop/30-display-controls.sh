# CLI utility for controlling backlight devices.
#
# This generally only means internal panels, e.g. built-in laptop screen
# (specifically any device that the kernel exposes a backlight sysfs API for
# backlight control under /sys/class/backlight)
AddPackage brightnessctl

# Wrapper that selects the internal display's backlight device instead of
# relying on brightnessctl's default selection, which can pick a GPU "ghost"
# device (e.g. nvidia_0) on hybrid-GPU laptops.
CopyFile /usr/local/bin/backlight 755

# CLI utility for communicating with the firmware of external monitors over a
# display connection (VGA/DVI/HDMI/DisplayPort/USB-C/...).
#
# Not all monitors support this and intermediate links between the display and
# the port, e.g. a KVM / USB hub / dock / ... can prevent this control path
# sometimes.
#
# For supported monitors, this allows sending certain commands, such as ones to
# change the brightness, contrast control, input source control, audio volume,
# etc.
AddPackage ddcutil
