# Networking configuration for the system
#
# This file includes setup for the connection manager (NetworkManager),
# DNS and DHCP setup, firewall / security hardening steps, etc.

# TODO: Firewall

###############################################################################
## NetworkManager
###############################################################################

# Install and enable NetworkManager
AddPackage networkmanager
CreateLink \
  /etc/systemd/system/multi-user.target.wants/NetworkManager.service \
  /usr/lib/systemd/system/NetworkManager.service

# Enable NetworkManager even hook service (dispatcher)
#
# This is a D-Bus activated service, which adds support for running scripts
# when NetworkManager reports network-related events.
#
# user scripts: /etc/NetworkManager/dispatcher.d
# default scripts: /usr/lib/NetworkManager/dispatcher.d/
CreateLink \
  /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service \
  /usr/lib/systemd/system/NetworkManager-dispatcher.service

###############################################################################
## DNS configuration (systemd-resolved)
###############################################################################

# Enable systemd-resolved as a local resolver that supports caching,
# encrypted DNS, per-network split-DNS and centrally managed DNS config.
CreateLink \
  /etc/systemd/system/multi-user.target.wants/systemd-resolved.service \
  /usr/lib/systemd/system/systemd-resolved.service

# Use systemd-resolved's local stub resolver (127.0.0.53) for applications
# that do not use glibc's NSS (Name Service Switch) directly (NSS can query
# systemd-resolved directly over D-Bus).
CreateLink /etc/resolv.conf /run/systemd/resolve/stub-resolv.conf

# Send per-connection DNS servers and routing domains to systemd-resolved.
CopyFile /etc/NetworkManager/conf.d/systemd-resolved.conf

# Configure global DNS for ordinary lookups. More-specific per-link routing
# domains continue to use their connection's DNS servers.
CopyFile /etc/systemd/resolved.conf.d/10-default-dns.conf

###############################################################################
## Opinionated NetworkManager privacy-hardening settings
###############################################################################

# Use randomized MAC addresses
# - Random MAC during Wi-Fi scanning
# - Randomize MAC for every connection
#   (You might want to override this for some connections, setting it to stable
#   if you need to have a stable preserved (but still randomized) identity on
#   that connection that doesn't change through reconnects)
CopyFile /etc/NetworkManager/conf.d/random_mac.conf

# Disable sending the system hostname to DHCP servers
# (You might want to override this for some connections)
CopyFile /etc/NetworkManager/conf.d/dhcp-hostname.conf

# Configure IPv6 address privacy
# - Use temporary, periodically rotating IPv6 addresses for outbound connections
# - Use a per-connection DHCPv6 client identifier
# - Use "stable-privacy" addresses (avoids exposing the interface's MAC address)
CopyFile /etc/NetworkManager/conf.d/ipv6-privacy.conf

# Enable mDNS (Multicast DNS) and link-local name resolution as resolve-only
# - Prevents advertising the hostname, but allows lookups
# (You might want to override this for some connections)
CopyFile /etc/NetworkManager/conf.d/llmnr-mdns.conf

###############################################################################
# User tooling
###############################################################################

AddPackage net-tools # Configuration tools for Linux networking
AddPackage bind # A complete, highly portable implementation of the DNS protocol
AddPackage tcpdump # Powerful command-line packet analyzer
