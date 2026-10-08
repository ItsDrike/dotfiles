# PipeWire is the low-level multimedia framework for capture and playback of
# both video and audio with minimal latency.

###############################################################################
# Core daemon, native PipeWire protocol, routing engine.
###############################################################################

AddPackage pipewire
AddPackage lib32-pipewire  # 32-bit compatibility variant

# Enable socket activation for PipeWire
CreateLink \
  /etc/systemd/user/sockets.target.wants/pipewire.socket \
  /usr/lib/systemd/user/pipewire.socket

###############################################################################
# Audio Support
###############################################################################

# Standard PipeWire audio server. This adds the modules/plugins loaded by the
# main pipewire daemon to provide audio handling support.
AddPackage pipewire-audio

# pipewire-pulse listens on the PulseAudio-compatible socket, translates the
# PulseAudio protocol and concepts into PipeWire objects, and communicates with
# the PipeWire daemon to route those client requests.
AddPackage pipewire-pulse
CreateLink \
  /etc/systemd/user/sockets.target.wants/pipewire-pulse.socket \
  /usr/lib/systemd/user/pipewire-pulse.socket

# pipewire-jack is an ABI-compatible replacement for libjack.so. JACK
# applications load it, and it connects them directly to PipeWire. It does not
# start a separate JACK server or listener socket.
AddPackage pipewire-jack

# ALSA is both the kernel audio interface (/dev/snd/*) and a userspace library
# (libasound) with a configurable plugin system. pipewire-alsa adds a PipeWire
# ALSA PCM plugin and ALSA configuration that makes the normal "default" ALSA
# device resolve to that plugin, which connects the application to PipeWire.
AddPackage pipewire-alsa

###############################################################################
# WirePlumber (Session & policy manager implementation for PipeWire)
###############################################################################

# PipeWire transports media but does not decide how devices and application
# streams should be connected. WirePlumber discovers audio devices, manages
# their profiles and defaults, restores saved routes and volumes, and
# automatically links streams to the appropriate input or output node.
#
# It does not process media or expose a client-facing socket; it applies policy
# to PipeWire's media graph through the native PipeWire protocol.
AddPackage wireplumber

# Select WirePlumber as PipeWire's session manager and start it whenever the
# PipeWire daemon is active.
CreateLink \
  /etc/systemd/user/pipewire-session-manager.service \
  /usr/lib/systemd/user/wireplumber.service
CreateLink \
  /etc/systemd/user/pipewire.service.wants/wireplumber.service \
  /usr/lib/systemd/user/wireplumber.service

###############################################################################
# RealtimeKit (bounded realtime scheduling for PipeWire)
###############################################################################

# PipeWire can request realtime scheduling for latency-sensitive audio threads
# through RealtimeKit's D-Bus API. RealtimeKit is a generic system service, not
# part of PipeWire: it authorizes requests and enforces priority, CPU-time, and
# per-user resource limits so that realtime clients cannot monopolize the CPU.
#
# It does not route or process media, PipeWire is usually its only consumer
# on most normal desktop systems though.
AddPackage rtkit
