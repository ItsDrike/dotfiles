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
