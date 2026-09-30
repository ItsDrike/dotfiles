AddPackage kbd # Console keyboard utilities; provides setleds for the initrd numlock service

# Extend mkinitcpio hooks configuration, adding Plymouth and sd-encrypt.
CopyFile /etc/mkinitcpio.conf.d/10-hooks.conf

# Enable numlock before the initrd's LUKS password / TPM pin prompt
CopyFile /etc/initcpio/install/sd-numlock 755
CopyFile /usr/lib/systemd/system/initrd-numlock.service 644
CreateLink \
  /usr/lib/systemd/system/initrd.target.wants/initrd-numlock.service \
  ../initrd-numlock.service

# Update the mkinitcpio presets to build UKIs
CopyFile /etc/mkinitcpio.d/linux-cachyos.preset
CopyFile /etc/mkinitcpio.d/linux.preset
