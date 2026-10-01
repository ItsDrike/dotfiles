SourceProfile gpu/nvidia.sh
SourceProfile gpu/nvidia-prime.sh
SourceProfile gpu/intel.sh
SourceProfile containers/docker.sh
SourceProfile containers/podman.sh

# Orca boots its Btrfs root filesystem from this subvolume.
printf '%s\n' 'rootflags=subvol=@bootstrap-root' > "$(CreateFile /etc/cmdline.d/10-root.conf)"

# Enables Intel VT-d DMA remapping.
# (for VFIO device passthrough and DMA isolation / security hardening)
printf '%s\n' 'intel_iommu=on' > "$(CreateFile /etc/cmdline.d/20-iommu.conf)"
