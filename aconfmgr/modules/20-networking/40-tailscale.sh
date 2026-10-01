# Tailscale mesh VPN service.
AddPackage tailscale

# Start tailscale service on boot
CreateLink \
  /etc/systemd/system/multi-user.target.wants/tailscaled.service \
  /usr/lib/systemd/system/tailscaled.service

# Machine-specific node identity, peer state, and runtime metadata.
IgnorePath '/var/lib/tailscale'
