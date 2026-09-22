config_root="$(dirname -- "${BASH_SOURCE[0]}")/.."

source "$config_root/profiles/nvidia.sh"

# Enables Intel VT-d DMA remapping.
# (for VFIO device passthrough and DMA isolation / security hardening)
printf '%s\n' 'intel_iommu=on' > "$(CreateFile /etc/cmdline.d/10-iommu.conf)"
