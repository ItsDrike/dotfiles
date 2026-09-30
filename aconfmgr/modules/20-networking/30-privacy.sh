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
