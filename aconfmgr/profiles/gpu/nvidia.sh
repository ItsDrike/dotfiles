# NVIDIA dGPU driver
#
# Installs the NVIDIA kernel modules and core userspace driver, for any host
# with an NVIDIA GPU, whether it's the only GPU or sits alongside another
# vendor's iGPU. Hybrid (iGPU + NVIDIA dGPU) hosts additionally need
# nvidia-prime.sh for PRIME render offload support.
#
# We use the open-source kernel modules: NVIDIA no longer ships proprietary
# modules for current-generation GPUs, and the open modules are the only
# supported option going forward. Modules are installed for both the
# linux-cachyos kernel (primary) and the stock arch linux kernel (fallback), so
# the fallback boot entry keeps working too.
#
# Recent nvidia-utils versions ship sane defaults out of the box that used to
# require manual setup, so these are not duplicated here:
# - DRM KMS (nvidia-drm.modeset) is enabled by default,
# - nouveau is blacklisted,
# - Vulkan ICD manifest for NVIDIA is included.
# - OpenGL, GLX and EGL support is included.
# - suspend/resume handling (kernel suspend notifiers, the VRAM spill path) is
#   preconfigured.
#
# We install the 32-bit version of nvidia-utils too, for Steam + Proton/Wine.
AddPackage linux-cachyos-nvidia-open
AddPackage nvidia-open
AddPackage nvidia-utils
AddPackage lib32-nvidia-utils

# Dynamic Boost: lets the platform shift power budget between CPU and dGPU
# under a shared thermal/power envelope while the dGPU is active. This is a
# laptop-only feature backed by platform-specific ACPI methods, so it's
# gated on the detected chassis type rather than being unconditional or
# split into its own laptop-only profile: it would just fail to start on a
# desktop, and this way the same file stays correct for any NVIDIA host.
if [[ "$(hostnamectl chassis 2>/dev/null)" == laptop ]]; then
    CreateLink \
        /etc/systemd/system/multi-user.target.wants/nvidia-powerd.service \
        /usr/lib/systemd/system/nvidia-powerd.service
fi
