# Virtual console configuration (TTY)
CopyFile /etc/vconsole.conf

# Use the standard getty template for automatic virtual terminals and tty1.
CreateLink \
  /etc/systemd/system/autovt@.service \
  /usr/lib/systemd/system/getty@.service
CreateLink \
  /etc/systemd/system/getty.target.wants/getty@tty1.service \
  /usr/lib/systemd/system/getty@.service
