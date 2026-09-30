# Rootful Docker for local development.
#
# Access remains sudo-only: membership in the docker group is dangerous, as it
# gives the user unrestricted root-equivalent permissions without needing to go
# through sudo.
AddPackage docker
AddPackage docker-buildx
AddPackage docker-compose

# Keep the mutable images, snapshots, volumes, and metadata state outside
# declarative configuration.
IgnorePath '/var/lib/docker'
IgnorePath '/var/lib/containerd'

# This directory holds CNI network configuration files. It is primarily used by
# Kubernetes, not Docker alone, however, Docker uses containerd, and its
# built-in CRI plugin creates this empty dir automatically.
CreateDir /etc/cni/net.d 700

# These directories hold externally supplied containerd extension binaries and
# libraries. The built-in optional-extension plugin creates them empty
# automatically, so declare them without hiding any future extension files.
CreateDir /opt/containerd 711
CreateDir /opt/containerd/bin 711
CreateDir /opt/containerd/lib 711

# When firewalld is active, Docker creates these permanent firewalld objects to
# assign its bridge interfaces to the docker zone and permit container
# forwarding. Docker owns their lifecycle.
IgnorePath '/etc/firewalld/zones/docker.xml'
IgnorePath '/etc/firewalld/policies/docker-forwarding.xml'

# Start Docker only when its local Unix socket is used. Long-running services
# that must restart at boot should explicitly enable docker.service instead.
CreateLink \
    /etc/systemd/system/sockets.target.wants/docker.socket \
    /usr/lib/systemd/system/docker.socket

# Configures:
#
# - Explicit network ranges (mostly default docker, though cut down and
#   explicit, we want to know and control exactly what IPs docker can reserve
#   to avoid conflicts with my other LAN networks, VPNs, tailscale, etc.)
#
#   * docker0 (default) network to use 172.17.0.1/16
#   * default address pools (used for created docker networks / auto-used in
#     docker compose), in order of preference:
#
#     * 172.18.0.0/16 (/24 allocations)
#     * 172.19.0.0/16 (/24 allocations)
#
# - Published ports to bind to localhost by default for both the default
#   docker0 and created user-defined / Docker Compose bridge networks. External
#   exposure therefore requires an explicit host address in the port mapping.
#
# - Explicit Docker DNS resolver at 172.17.0.1, which we then make
#   systemd-resolved listen on. For detail on why, see the explanation comment
#   on adding this extra listener to systemd-resolved.
#
# - Maximum log file size and max number of log files which Docker can retain.
#
# Note that we're intentionally not configuring the storage driver, as since
# Docker 29, the containerd image store is used by default instead.
CopyFile /etc/docker/daemon.json

# Add an extra listener within the docker0 network, on 172.17.0.1:53.
#
# For containers on the default docker0 network, Docker will configure their
# DNS to this IP address (Docker auto-creates the /etc/resolv.conf in the
# container to configure the DNS based on the selected `dns` from daemon.json /
# explicit passed `--dns` flag).
#
# For containers on other (user defined / docker compose default) networks,
# Docker uses an embedded DNS resolver (part of dockerd), which binds to
# 127.0.0.11:53 inside the containers network namespace, and forwards requests
# to the configured DNS (so in our case, to systemd-resolved at 172.17.0.1:53).
#
# Using the host systemd-resolved from docker is important, because it lets us
# properly utilize the host split DNS, and brings other general advantages that
# systemd-resolved normally carries (DNS over TLS, DNSSEC, LLMNR, MulticastDNS,
# Cache, ...)
#
# If we didn't set `dns` in docker.json explicitly, docker's default docker0
# network would instead copy the host's /etc/resolv.conf config directly,
# though if it would find the systemd-resolved default loopback listener
# (127.0.0.53:53) there, it would trigger a special case, making Docker copy
# /run/systemd/resolve/resolv.conf instead, carrying the configured active
# primary resolvers.
#
# That default approach is therefore not desirable, because the primary
# configured DNS server by systemd-resolved may be DNS-over-TLS only, or may
# not be the right server for a given lookup because of split DNS, so this
# default handling is not actually very good.
CopyFile /etc/systemd/resolved.conf.d/20-docker-dns.conf
