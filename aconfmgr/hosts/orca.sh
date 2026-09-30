config_root="$(dirname -- "${BASH_SOURCE[0]}")/.."

source "$config_root/profiles/gpu/nvidia.sh"
source "$config_root/profiles/gpu/nvidia-prime.sh"
source "$config_root/profiles/gpu/intel.sh"
source "$config_root/profiles/containers/docker.sh"
source "$config_root/profiles/containers/podman.sh"

# Orca boots its Btrfs root filesystem from this subvolume.
printf '%s\n' 'rootflags=subvol=@bootstrap-root' > "$(CreateFile /etc/cmdline.d/10-root.conf)"

# Enables Intel VT-d DMA remapping.
# (for VFIO device passthrough and DMA isolation / security hardening)
printf '%s\n' 'intel_iommu=on' > "$(CreateFile /etc/cmdline.d/20-iommu.conf)"
