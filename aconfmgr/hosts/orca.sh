config_root="$(dirname -- "${BASH_SOURCE[0]}")/.."

source "$config_root/profiles/gpu/nvidia.sh"
source "$config_root/profiles/gpu/nvidia-prime.sh"
source "$config_root/profiles/gpu/intel.sh"

# Enables Intel VT-d DMA remapping.
# (for VFIO device passthrough and DMA isolation / security hardening)
printf '%s\n' 'intel_iommu=on' > "$(CreateFile /etc/cmdline.d/10-iommu.conf)"
