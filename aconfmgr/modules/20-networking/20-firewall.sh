# Install and enable firewalld
AddPackage firewalld
CreateLink \
  /etc/systemd/system/multi-user.target.wants/firewalld.service \
  /usr/lib/systemd/system/firewalld.service

# Configure firewalld + the individual zones:
# - By default, the `public` zone will be used for every network interface.
# - For the `tailscale0` interface, the `tailnet` zone is used instead.
# - The overridden `home` zone is unused by default and configures more
#   permissive rules for explicitly trusted local networks.
# - The overridden `work` zone currently remains restrictive without SSH.
#
# NetworkManager has a built-in firewalld integration, allowing a connection to
# specify the firewall zone to be auto-configured for its interface with:
# `sudo nmcli connection modify "[SSID]" connection.zone home`.
#
# Alternatively, a zone can be manually assigned to an interface with:
# `firewall-cmd --zone=home --change-interface=wlp0s20f3`.
CopyFile /etc/firewalld/firewalld.conf
CopyFile /etc/firewalld/zones/public.xml
CopyFile /etc/firewalld/zones/home.xml
CopyFile /etc/firewalld/zones/tailnet.xml
CopyFile /etc/firewalld/zones/work.xml
